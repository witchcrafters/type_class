defprotocol TypeClass.Property.Generator do
  @moduledoc ~S"""
  Data generator protocol for property checks. The more variation the better.
  """

  @fallback_to_any true

  @doc ~S"""
  Generate a random example of datatype.

  ## Examples

      defimpl TypeClass.Property.Generator, for: Integer do
        def generate(_), do: :rand.uniform(1000) * Enum.random([1, 1, 1, -1])
      end

      defimpl TypeClass.Property.Generator, for: BitString do
        def generate(_) do
          Stream.unfold("", &({&1, :rand.uniform(90)}))
          |> Stream.drop(1)
          |> Stream.take(:rand.uniform(4))
          |> Enum.to_list()
          |> List.to_string()
        end
      end

  """
  def generate(sample)
end

defimpl TypeClass.Property.Generator, for: Any do
  @moduledoc false

  def generate(_any) do
    [
      "",
      2,
      1.1,
      [],
      {},
      %{},
      fn _ -> nil end
    ]
    |> Enum.random()
    |> TypeClass.Property.Generator.generate()
  end
end

defimpl TypeClass.Property.Generator, for: TypeClass.Property.Generator.Custom do
  @moduledoc false

  def generate(generator) do
    generate(generator, TypeClass.Property.Generator.generate(nil))
  end

  def generate(%{generator: generator}, seed), do: generator.(seed)
end

defimpl TypeClass.Property.Generator, for: Function do
  @moduledoc false

  def generate(_) do
    Enum.random([
      &inspect/1,
      &is_number/1,
      fn id -> id end
    ])
  end
end

defimpl TypeClass.Property.Generator, for: Integer do
  @moduledoc false

  def generate(_), do: :rand.uniform(1000) * Enum.random([1, 1, 1, -1])
end

defimpl TypeClass.Property.Generator, for: Float do
  @moduledoc false

  def generate(_) do
    a = TypeClass.Property.Generator.generate(1)
    b = TypeClass.Property.Generator.generate(1)
    a / b
  end
end

defimpl TypeClass.Property.Generator, for: BitString do
  @moduledoc false

  def generate(_) do
    ""
    |> Stream.unfold(&{&1, :rand.uniform(90)})
    |> Stream.drop(1)
    |> Stream.take(:rand.uniform(20))
    |> Enum.to_list()
    |> List.to_string()
  end
end

defimpl TypeClass.Property.Generator, for: List do
  @moduledoc false

  def generate(_) do
    1
    |> Stream.unfold(fn acc ->
      next =
        [0, 0, 0, 0, 0.0, 0.0, 0.0, 0.0, "", "", "", "", "", "", {}, [], %{}]
        |> Enum.random()
        |> TypeClass.Property.Generator.generate()

      {acc, next}
    end)
    |> Stream.drop(1)
    |> Stream.take(:rand.uniform(4))
    |> Enum.to_list()
  end
end

defimpl TypeClass.Property.Generator, for: Tuple do
  @moduledoc false

  def generate(_) do
    []
    |> TypeClass.Property.Generator.generate()
    |> List.to_tuple()
  end
end

defimpl TypeClass.Property.Generator, for: Map do
  @moduledoc false

  def generate(_) do
    {0, 1}
    |> Stream.unfold(fn acc ->
      key = ["", 0] |> Enum.random() |> TypeClass.Property.Generator.generate()

      value =
        [0, 0, 0, 0, 0.0, 0.0, 0.0, 0.0, "", "", "", "", "", "", {}, [], %{}]
        |> Enum.random()
        |> TypeClass.Property.Generator.generate()

      next = {key, value}

      {acc, next}
    end)
    |> Stream.drop(1)
    |> Stream.take(:rand.uniform(4))
    |> Enum.to_list()
    |> Enum.into(%{})
  end
end

defimpl TypeClass.Property.Generator, for: MapSet do
  @moduledoc false

  def generate(_) do
    []
    |> TypeClass.Property.Generator.generate()
    |> Enum.reduce(MapSet.new(), fn element, set -> MapSet.put(set, element) end)
  end
end
