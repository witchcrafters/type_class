defmodule TypeClass.Dependency do
  defmacro __using__(_) do
    quote do
      import unquote(__MODULE__)
      unquote(__MODULE__).set_up
    end
  end

  defmacro set_up do
    quote do
      import TypeClass.Utility.Attribute
      register(:extend, accumulate: true)
    end
  end

  defmacro extend(parent_class) do
    quote do
      use unquote(parent_class), class: :alias
      @extend unquote(parent_class)
    end
  end

  defmacro run do
    quote do
      def __dependencies__, do: @extend
    end
  end
end
