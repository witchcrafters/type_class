defmodule TypeClass.Property do
  @moduledoc "A *very* simple prop checker"

  alias TypeClass.Utility.Module


  @doc "Ensure that the type class has defined properties"
  @spec ensure!() :: no_return
  defmacro ensure! do
    quote do
      case Code.ensure_loaded(__MODULE__.Property) do
        {:module, _prop_submodule} -> nil

        {:error, :nofile} ->
          raise TypeClass.Property.Undefined.new(__MODULE__)
      end
    end
  end

  @doc "Run all properties for the type class"
  @spec run!(module, module, atom, non_neg_integer) :: no_return
  def run!(datatype, class, prop_name, times \\ 100) do
    property_module = Module.append(class, Property)
    example_module = Module.append(TypeClass.Property.Generator, datatype)

    Stream.repeatedly(fn ->
      unless apply(property_module, prop_name, [example_module.generate(nil)]) do
        raise TypeClass.Property.FailedCheck.new(datatype, class, prop_name)
      end
    end)
    |> Enum.take(times)
  end
end
