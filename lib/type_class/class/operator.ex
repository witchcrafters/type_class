defmodule TypeClass.Class.Operator do

  defmacro set_up do
    quote do
      Module.register_attribute __MODULE__, :operator, accumulate: true
      # find function that it refers to
    end
  end

  defmacro run do
    quote do
      @dependancies Module.get_attribute(__MODULE__, :depend)

      Enum.each(@dependancies, fn dep ->
        dep
        |> Classy.Class.Name.new
        |> Protocol.assert_impl!(__MODULE__)
      end)

      def __dependancies__, do: @dependancies
    end
  end
end
