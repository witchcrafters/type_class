defmodule TypeClass.Class.Dependancy do

  defmacro __using__(_) do
    quote do
      require unquote(__MODULE__)
      alias   unquote(__MODULE__)
    end
  end

  defmacro set_up do
    quote do
      Module.register_attribute __MODULE__, :depend, accumulate: true
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

  defmacro use_dependancies do
    quote do
      Enum.map(__DEPENDANCIES__, fn dep -> Kernel.use(dep, :class) end)
    end
  end
end
