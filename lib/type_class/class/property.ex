defmodule TypeClass.Class.Property do

  use TypeClass.Utility.Attribute

  defmacro __using__(_) do
    quote do
      require unquote(__MODULE__)
      alias   unquote(__MODULE__)
    end
  end

  defmacro set_up do
    quote do: Attribute.register(:property, accumulate: true)
  end

  defmacro run do
    quote do
      def __PROPERTIES__, do: Attribute.get(:property)

      # run props with QuickCheck or equivalent
    end
  end
end
