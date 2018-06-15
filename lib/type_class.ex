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
            Semigroup.concat(empty(a), a) == a
          end

          def right_identity(data) do
            a = generate(data)
            Semigroup.concat(a, empty(a)) == a
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

  ### Protocol

  `defclass Foo` generates a `Foo.Proto` submodule that holds all of the functions
  to be implemented (it's a normal protocol). It's a very lightweight & straightforward,
  but The `Protocol` should never need to be called explicitly.

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
        import TypeClass.Property.Generator, only: [generate: 1]
        import TypeClass.Property.Generator.Custom

        require TypeClass.Property

        use TypeClass.Dependency

        Module.register_attribute(__MODULE__, :force_type_class, [])
        @force_type_class false

        Module.register_attribute(__MODULE__, :class_methods, [])
        @class_methods false

        unquote(body)

        @doc false
        def __force_type_class__, do: @force_type_class

        TypeClass.run_where!()
        TypeClass.Dependency.run()
        TypeClass.Property.ensure!()
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
      instance = Module.concat([unquote(class), Proto, unquote(datatype)])

      defimpl unquote(class).Proto, for: unquote(datatype) do
        import TypeClass.Property.Generator.Custom

        Module.register_attribute(__MODULE__, :force_type_instance, [])
        @force_type_instance false

        @doc false
        def __custom_generator__, do: false
        defoverridable __custom_generator__: 0

        unquote(body)

        @doc false
        def __force_type_instance__, do: @force_type_instance
      end

      cond do
        unquote(class).__force_type_class__() ->
          IO.warn("""
          The type class #{unquote(class)} has been forced to bypass \
          all property checks for all data types. This is very rarely valid, \
          as all type classes should have properties associted with them.

          For more, please see the TypeClass README:
          https://github.com/expede/type_class/blob/master/README.md
          """)

        instance.__force_type_instance__() ->
          IO.warn("""
          The data type #{unquote(datatype)} has been forced to skip property \
          validation for the type class #{unquote(class)}

          This is sometimes valid, since TypeClass's property checker \
          may not be able to accurately validate all data types correctly for \
          all possible cases. Forcing a type instance in this way is like telling \
          the checker "trust me this is correct", and should only be used as \
          a last resort.

          For more, please see the TypeClass README:
          https://github.com/expede/type_class/blob/master/README.md
          """)

        true ->
          unquote(datatype) |> conforms(to: unquote(class))
      end
    end
  end

  @doc ~S"""
  Convenience alises for `definst/3`

  ## Implicit `class`
  ### Examples

  definst Semigroup, for: List do
  def concat(a, b), do: a ++ b
  end

  ## No body

  When you only want to check the properties (ex. when there is no `where` block)

  ### Examples

      # Depenency
      defclass Base do
        where do
          def plus_one(a)
        end

        properties do
          def pass(_), do: true
        end
      end

      # No `where`
      defclass MoreProps do
        extend Base

        properties do
          def yep(a), do: equal?(a, a)
        end
      end

      definst Base, for: Integer do
        def plus_one(a), do: a + 5
      end

      definst MoreProps, for: Integer

  """
  defmacro definst(class, for: datatype) do
    quote do
      definst unquote(class), for: unquote(datatype) do
        # Intentionally blank; hooking into definst magic
      end
    end
  end

  @doc "Variant of `definst/2` for use inside of a `defstruct` module definition"
  defmacro definst(class, do: body) do
    quote do: definst(unquote(class), for: __MODULE__, do: unquote(body))
  end

  @doc ~S"""
  Describe functions to be instantiated. Creates an internal protocol.

  ## Examples

      defclass Semigroup do
        where do
          def concat(a, b)
        end

        # ...
      end

  """
  defmacro where(do: fun_specs) do
    Module.put_attribute(__CALLER__.module, :class_methods, fun_specs)
  end

  defmacro run_where! do
    class = __CALLER__.module
    fun_specs = Module.get_attribute(class, :class_methods)
    proto = (Module.split(class) ++ ["Proto"]) |> Enum.map(&String.to_atom/1)

    fun_stubs =
      case fun_specs do
        nil -> []
        {:__block__, _ctx, funs} -> funs
        fun = {:def, _ctx, _inner} -> [fun]
      end

    delegates =
      fun_stubs
      |> List.wrap()
      |> Enum.map(fn
        {:def, ctx, fun} ->
          {
            :defdelegate,
            ctx,
            fun ++ [[to: {:__aliases__, [alias: false], proto}]]
          }

        ast ->
          ast
      end)

    quote do
      defprotocol Proto do
        @moduledoc ~s"""
        Protocol for the `#{unquote(class)}` type class

        For this type class's API, please refer to `#{unquote(class)}`
        """

        import TypeClass.Property.Generator.Custom

        Macro.escape(unquote(fun_specs), unquote: true)
      end

      unquote(delegates)
    end
  end

  @doc ~S"""
  Define properties that any instance of the type class must satisfy.
  They must by unary (takes a data seed), and return a boolean (true if passes).

  `generate` is automatically imported

  ## Examples

      defclass Semigroup do
        # ...

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
  defmacro properties(do: prop_funs) do
    class = __CALLER__.module
    proto = Module.concat(Module.split(class) ++ [Proto])

    leaf =
      class
      |> Module.split()
      |> List.last()
      |> List.wrap()
      |> Module.concat()

    quote do
      defmodule Property do
        @moduledoc false

        import TypeClass.Property, only: [equal?: 2]

        alias unquote(class)
        alias unquote(proto), as: unquote(leaf)

        unquote(prop_funs)
      end
    end
  end

  @doc "Delegate to a local function"
  defmacro defalias(fun_head, as: as_name) do
    quote do
      defdelegate unquote(fun_head), to: __MODULE__, as: unquote(as_name)
    end
  end

  @doc "Check that a datatype conforms to the class hierarchy and properties"
  defmacro conforms(datatype, opts) do
    class = Keyword.get(opts, :to)

    quote do
      for dependency <- unquote(class).__dependencies__ do
        proto = Module.concat(Module.split(dependency) ++ ["Proto"])

        # NOTE: does not follow chain if dependency has no `where`
        if Exceptional.Safe.safe(&Protocol.assert_protocol!/1).(proto) == :ok do
          Protocol.assert_impl!(proto, unquote(datatype))
        end
      end

      for {prop_name, _one} <- unquote(class).Property.__info__(:functions) do
        TypeClass.Property.run!(unquote(datatype), unquote(class), prop_name)
      end
    end
  end

  @doc "Variant of `conforms/2` that can be called within a data module"
  defmacro conforms(opts) do
    quote do: conforms(__MODULE__, unquote(opts))
  end
end
