defmodule TypeClass do
  @moduledoc ~S"""
  Helpers for defining (bootstrapped, semi-)principled type classes

  Generates a few modules and several functions and aliases. There is no need
  to use these internals directly, as the top-level API will suffice for actual
  productive use.

  ## Example

  defclass MyApp.Monoid do
  @extend MyApp.Semigroup

  @doc "Appends the identity to the monoid"
  @operator &&&
  @spec append_id(Monoid.t) :: Monoid.t
  def append_id(a), do: identity <> a

  where do
  @operator ^
  identity(any) :: any
  end

  defproperty reflexivity(a), do: a == a

  properties do
  def symmetry(a, b), do: equal?(a, b) == equal?(b, a)

  def transitivity(a, b, c) do
  equal?(a, b) && equal?(b, c) && equal?(a, c)
  end
  end
  end


  ## Structure
  A `Class` is composed of several parts:
  - Dependencies
  - Protocol
  - Properties


  ### Dependencies

  Dependencies are the other type classes that the type class being
  defined extends. For istance, . It only needs the immediate parents in
  the chain, as those type classes will have performed all of the checks required
  for their parents.


  ### Protocol

  `Class` generates a `Foo.Protocol` submodule that holds all of the functions
  to be implemented. It's a very lightweight/straightforward macro. The `Protocol`
  should never need to be called explicitly, as all of the functions will be
  aliased in the top-level API.


  ### Properties

  Being a (quasi-)principled type class also means having properties. Users must
  define _at least one_ property, plus _at least one_ sample data generator.
  These will be run at compile time (in dev and test environments),
  and will throw errors if they fail.
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
