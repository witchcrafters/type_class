defmodule TypeClass.Property do

  defmacro __using__(_) do
    quote do
      import unquote(__MODULE__)
    end
  end

  def run_prop(datatype, class, prop_name, times \\ 500) do
    quote do
      Steam.repeatedly(fn ->
        unless apply(unquote(class).Property, fun_name, []) do
          unquote(datatype)
          |> TypeClass.Property.FailedCheck.new(unquote(class), unquote(prop_name))
          |> raise
        end
      ) |> Enum.take(times)
    end
  end
end
