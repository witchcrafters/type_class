defmodule TypeClass do
  @moduledoc ~S"""
  Helpers for defining (bootstrapped, semi-)principled type classes

  Generates a few modules and several functions and aliases. There is no need
  to use these internals directly, as the top-level API will suffice for actual
  productive use.

  ## Example

      defclass Semigroup do
        use Operator

        where do
          @operator :<|>
          def concat(a, b)
        end

        properties do
          def associative(data) do
            a = generate(data)
            b = generate(data)
            c = generate(data)

            left  = a |> Semigroup.concat(b) |> Semigroup.concat(c)
            right = Semigroup.concat(a, Semigroup.concat(b, c))

            left == right
          end
        end
      end

      definst Semigroup, for: List do
        def concat(a, b), do: a ++ b
      end

      defclass Monoid do
        extend Semigroup

        where do
          def empty(sample)
        end

        properties do
          def left_identity(data) do
            a = generate(data)
            Semigroup.concat(Monoid.empty(a), a) == a
          end

          def right_identity(data) do
            a = generate(data)
            Semigroup.concat(a, Monoid.empty(a)) == a
          end
        end
      end

      definst Monoid, for: List do
        def empty(_), do: []
      end


  ## Internal Structure

  A `type_class` is composed of several parts:
  - Dependencies
  - Protocol
  - Properties


  ### Dependencies

  Dependencies are the other type classes that the type class being
  defined extends. For instance, Monoid has a Semigroup dependency.

  It only needs the immediate parents in
  the chain, as those type classes will have performed all of the checks required
  for their parents.


  ### Proto

  `defclass Foo` generates a `Foo.Proto` submodule that holds all of the functions
  to be implemented (it's a normal protocol). It's a very lightweight & straightforward,
  but The `Protocol` should never need to be called explicitly, as all of the functions will be
  aliased in the top-level API, and will be automatically aliased/imported with the
  `use` variants.

  Macro: `where do`
  Optional


  ### Properties

  Being a (quasi-)principled type class also means having properties. Users must
  define _at least one_ property, plus _at least one_ sample data generator.
  These will be run at compile time and refuse to compile if they don't pass.

  All custom structs need to implement the `TypeClass.Property.Generator` protocol.
  This is called automatically by the prop checker. Base types have been implemented
  by this library.

  Please note that class functions are aliased to the last segment of their name.
  ex. `Foo.Bar.MyClass.quux` is automatically usable as `MyClass.quux` in the `proprties` block

  Macro: `properties do`
  Non-optional

  """

  @doc ~S"""
  Top-level wrapper for all type class modules. Used as a replacement for `defmodule`.

  ## Examples

      defclass Semigroup do
        where do
          def concat(a, b)
        end

        properties do
          def associative(data) do
            a = generate(data)
            b = generate(data)
            c = generate(data)

            left  = a |> Semigroup.concat(b) |> Semigroup.concat(c)
            right = Semigroup.concat(a, Semigroup.concat(b, c))

            left == right
          end
        end
      end

  """
  defmacro defclass(class_name, do: body) do
    quote do
      defmodule unquote(class_name) do
        import TypeClass.Property.Generator, except: [impl_for: 1, impl_for!: 1]
        require TypeClass.Property
        use TypeClass.Dependency

        unquote(body)

        defmacro __using__(:class) do
          quote do
            use unquote(__MODULE__), class: :import
          end
        end

        defmacro __using__(class: :import) do
          class = unquote(class_name) # Help compiler with unwrapping quotes

          case Code.ensure_loaded(unquote(class_name).Proto) do
            {:module, proto} ->
              quote do
                import unquote(class)
                import unquote(proto), except: [impl_for: 1, impl_for!: 1]
              end

            {:error, :nofile} ->
              quote do: import unquote(class)
          end
        end

        defmacro __using__(class: :alias) do
          class = unquote(class_name) |> Module.split |> List.last |> List.wrap |> Module.concat
          proto = unquote(class_name).Proto

          case Code.ensure_loaded(proto) do
            {:module, proto} ->
              quote do
                alias unquote(__MODULE__)
                alias unquote(proto), as: unquote(class)
              end

            {:error, :nofile} ->
              quote do: alias unquote(class)
          end
        end

        defmacro __using__(class: :alias, as: as_name) do
          class = unquote(class_name) # Help compiler with unwrapping quotes

          case Code.ensure_loaded(unquote(class_name).Proto) do
            {:module, proto} ->
              quote do
                alias unquote(class)
                alias unquote(proto), as: unquote(as_name)
              end

            {:error, :nofile} ->
              quote do: alias unquote(class)
          end
        end

        TypeClass.Dependency.run
        TypeClass.Property.ensure!
      end
    end
  end

  @doc ~S"""
  Define an instance of the type class. The rough equivalent of `defimpl`.
  `defimpl` will check the properties at compile time, and prevent compilation
  if the datatype does not conform to the protocol.

  ## Examples

      definst Semigroup, for: List do
        def concat(a, b), do: a ++ b
      end

  """
  defmacro definst(class, opts, do: body) do
    [for: datatype] = opts

    quote do
      for dependency <- unquote(class).__dependencies__ do
        Protocol.assert_impl!(dependency, unquote datatype)
      end

      defimpl unquote(class).Proto, for: unquote(datatype), do: unquote(body)

      for {prop_name, _one} <- unquote(class).Property.__info__(:functions) do
        TypeClass.Property.run!(unquote(datatype), unquote(class), prop_name)
      end
    end
  end

  @doc ~S"""
  Convenience function for `defprotocol ClassName.Proto`. Adds some
  """
  defmacro where(do: fun_specs) do
    class = __CALLER__.module

    quote do
      defprotocol Proto do
        @moduledoc ~s"""
        Protocol for the `#{unquote(class)}` type class

        For this type class's API, please refer to `#{unquote(class)}`
        """

        import TypeClass.Property.Generator, except: [impl_for: 1, impl_for!: 1]

        Macro.escape unquote(fun_specs), unquote: true
      end
    end
  end

  defmacro properties(do: prop_funs) do
    class = __CALLER__.module
    leaf  = class |> Module.split |> List.last |> List.wrap |> Module.concat
    proto = Module.concat(Module.split(class) ++ [Proto])

    quote do
      defmodule Property do
        @moduledoc ~S"""
        Properties for the `#{unquote(class)}` type class

        For this type class's functions, please refer to `#{unquote(class)}`
        """

        alias unquote(class)
        alias unquote(proto), as: unquote(leaf)

        unquote(prop_funs)
      end
    end
  end
end
