defmodule TypeClass.Property do
  alias __MODULE__

  @spec check_all([fun], [fun], pos_integer) :: :ok | Property.Error.t
  def check_all(properties, data_generators, times \\ 100) do
    class.__PROPERTIES__
    |> Enum.each(fn prop ->
      Enum.reduce(class. )
      check(prop, times)
    end)
  end
end
