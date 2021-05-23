defmodule TypeClass.Property do
  @moduledoc "A *very* simple prop checker"

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

  @doc "Check all properties for the type class"
  @spec check!(module(), module(), atom(), non_neg_integer()) :: no_return()
  def check!(datatype, class, prop_name, times \\ 100) do
    property_module = Module.concat(class, Property)
    custom_generator = Module.concat([class, "Proto", datatype]).__custom_generator__()

    data_generator =
      if custom_generator do
        custom_generator
      else
        Module.concat(TypeClass.Property.Generator, datatype).generate(nil)
      end

    fn ->
      unless apply(property_module, prop_name, [data_generator]) do
        raise TypeClass.Property.FailedCheckError.new(datatype, class, prop_name)
      end
    end
    |> Stream.repeatedly()
    |> Enum.take(times)
  end

  # FIXME doc & typespec
  def check_all!(datatype, class, times \\ 100) do
    for {prop_name, _one} <- Module.concat(class, Property).__info__(:functions) do
      TypeClass.Property.check!(datatype, class, prop_name, times)
    end
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
      is_float(left) -> Float.round(left, 5) == Float.round(right, 5)
      true -> left == right
    end
  end
end
