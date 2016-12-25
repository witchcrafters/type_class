defmodule TypeClass.Class.Dependency do
  use TypeClass.Utility.Attribute

  defmacro __using__(_) do
    quote do
      require TypeClass.Utility.Attribute # Must be first

      import unquote(__MODULE__)
      unquote(__MODULE__).set_up
    end
  end

  defmacro set_up do
    quote do
      TypeClass.Utility.Attribute.register(:extend, accumulate: true)
    end
  end

  defmacro extend(parent_class) do
    quote do
      use unquote(parent_class), :class # use & ensure it actually is a class
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
