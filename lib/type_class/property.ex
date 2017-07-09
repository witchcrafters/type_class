defmodule TypeClass.Property do
  @moduledoc "A *very* simple prop checker"

  alias TypeClass.Utility.Module

  @doc "Ensure that the type class has defined properties"
  @spec ensure!() :: no_return()
  defmacro ensure! do
    quote do
      case Code.ensure_loaded(__MODULE__.Property) do
        {:module, _prop_submodule} ->
          nil

        {:error, :nofile} ->
          raise TypeClass.Property.UndefinedError.new(__MODULE__)
      end
    end
  end

  @doc "Run all properties for the type class"
  @spec run!(module(), module(), atom(), non_neg_integer()) :: no_return()
  def run!(datatype, class, prop_name, times \\ 100) do
    property_module = Module.append(class, Property)
    example_module  = Module.append(TypeClass.Property.Generator, datatype)

    fn ->
      unless apply(property_module, prop_name, [example_module.generate(nil)]) do
        raise TypeClass.Property.FailedCheckError.new(datatype, class, prop_name)
      end
    end
    |> Stream.repeatedly()
    |> Enum.take(times)
  end

  @doc ~S"""
  Check for equality while handling special cases that normally don't equate in Elixir.
  For example, only check float accuracy to 5 decimal places due to internal rounding
  mismatches from applying functions in differing order. This isn't totally theoretically
  accurate, but is in line with the spirit of Floats.
  """
  @spec equal?(any(), any()) :: boolean()
  def equal?(left, right) do
    cond do
      is_function(left) -> left.("foo") == right.("foo")
      is_float(left)    -> Float.round(left, 5) == Float.round(right, 5)
      true              -> left == right
    end
  end
end
