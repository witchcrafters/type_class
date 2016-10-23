defmodule TypeClass.Class do
  @moduledoc ~S"""
  Helpers for defining (bootstrapped) principled type classes

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
  - Dependancies
  - Protocol
  - Properties


  ### Dependancies

  Dependancies are the other type classes that the type class being
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
  use TypeClass.Utility.Attribute

  use TypeClass.Class.Dependancy
  use TypeClass.Class.Property
  use TypeClass.Class.Protocol

  defmacro __using__(_) do
    quote do
      require unquote(__MODULE__)
      import  unquote(__MODULE__)
    end
  end

  defmacro defclass(class_name, do: body) do
    quote do
      TypeClass.Class.set_up
      use Operator

      unquote(body)

      defmacro __using__(:class) do
        require unquote(class_name)
        import  unquote(class_name)
      end

      TypeClass.Class.run
    end
  end

  defmacro set_up do
    quote do
      Dependancy.use
      Property.use
      Protocol.use
    end
  end

  defmacro run do
    quote do
      Dependancy.run
      Property.run
      Protocol.run
    end
  end
end
