defmodule Superclass.Class do
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
  use Superclass.Utility.Attribute

  use Superclass.Class.Dependency
  use Superclass.Class.Property
  use Superclass.Class.Protocol

  defmacro __using__(_) do
    quote do: import unquote(__MODULE__)
  end

  defmacro defclass(class_name, do: body) do
    quote do
      defmodule unquote(class_name) do
        # Superclass.Class.set_up
        # use Operator

        defmacro __using__(:class) do
          quote do
            import unquote(class_name)
          end
        end

        unquote(body)

        # Superclass.Class.run
      end
    end
  end

  def set_up do
    Dependency.use
    Property.use
    Protocol.use
  end

  defmacro run do
    Dependency.run
    Protocol.run
    Property.run
  end
end
