defmodule TypeClass.Class.Property do

  defmacro set_up do
    quote do
      Module.register_attribute __MODULE__, :property, accumulate: true
    end
  end

  defmacro run do
    quote do
      @props Module.get_attribute(__MODULE__, :property)
      def __properties__, do: @props

      # run props with QuickCheck or equivalent
    end
  end
end
