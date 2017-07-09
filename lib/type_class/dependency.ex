defmodule TypeClass.Dependency do
  @moduledoc ~S"""
  Helpers for setting type class dependencies
  """

  @type ast :: tuple()

  defmacro __using__(_) do
    quote do
      import unquote(__MODULE__)
      unquote(__MODULE__).set_up()
    end
  end

  @doc "Set up the dependency collection from `extend`"
  @spec set_up() :: ast()
  defmacro set_up do
    quote do
      import TypeClass.Utility.Attribute
      register(:extend, accumulate: true)
    end
  end

  @doc ~S"""
  Set a type class dependency.
  ie: another type class that need to be `definst`ed before this one.

  ## Examples

      defmodule Quux do
        extend Foo
        extend Bar
        extend Baz

        # ...
      end

  """
  @spec extend(module()) :: ast()
  defmacro extend(parent_class) do
    quote do
      require unquote(parent_class)
      @extend unquote(parent_class)
    end
  end

  defmacro extend(parent_class, alias: true) do
    quote do
      extend unquote(parent_class)
      alias unquote(parent_class)
    end
  end

  defmacro extend(parent_class, alias: alias_as) do
    quote do
      extend unquote(parent_class)
      alias unquote(parent_class), as: unquote(alias_as)
    end
  end

  @doc "The opposite of `set_up/1`: collect dependencies"
  @spec run() :: ast()
  defmacro run do
    quote do
      def __dependencies__, do: @extend
    end
  end
end
