defmodule TypeClass.Property.DataGenerator do
  # Generate Prop test inputs

  defmacro __using__(_) do
    quote do
      require unquote(__MODULE__)
      import  unquote(__MODULE__)
    end
  end

  defmacro defgenerator(unique_name, do: body) do
    quote do
      def __DATA_GENERATOR__(unquote(unique_name)) do: unquote(body)
    end
  end
end
