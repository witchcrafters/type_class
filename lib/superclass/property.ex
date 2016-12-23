defmodule Superclass.Property do
  alias __MODULE__

  defmacro __using__(_) do
    quote do
      require unquote(__MODULE__)
      alias   unquote(__MODULE__)
    end
  end

  # defmacro defproperty(name, )

  @spec check_all([fun], [fun], pos_integer) :: :ok | Property.Error.t
  def check_all(properties, data_generators, times \\ 100) do
    # properties
    # |> Enum.each(fn prop ->
    #   # Enum.reduce(class.__PROPERTY)
    #   check(prop, times)
    # end)
  end
end
