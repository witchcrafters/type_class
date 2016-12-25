defmodule TypeClass.Property do
  defmacro ensure! do
    quote do
      case Code.ensure_loaded(__MODULE__.Property) do
        {:module, _prop_submodule} -> nil

        {:error, :nofile} ->
          raise TypeClass.Property.Undefined.new(__MODULE__)
      end
    end
  end

  def run!(datatype, class, prop_name, times \\ 500) do
    property_module = Module.concat(class, Property)

    Stream.repeatedly(fn ->
      unless apply(property_module, prop_name, []) do
        datatype
        |> TypeClass.Property.FailedCheck.new(class, prop_name)
        |> raise
      end
    end) |> Enum.take(times)
  end
end
