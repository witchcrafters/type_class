defmodule Superclass.Class.Dependency do
  use Superclass.Utility.Attribute

  defmacro __using__(_) do
    quote do
      import unquote(__MODULE__)
      require Superclass.Utility.Attribute
    end
  end

  defmacro set_up do
    quote do
      Attribute.register(:extend, accumulate: true)
    end
  end

  defmacro extend(parent_class) do
    quote do
      use unquote(parent_class), :class
      @extend unquote(parent_class)
    end
  end

  defmacro run do
    quote do
      unquote(__MODULE__).create_dependencies_meta
    end
  end

  defmacro create_dependencies_meta do
    quote do
      def __dependencies__, do: @extend
    end
  end
end
