defprotocol TypeClass.Property.Generator do
  def generate(sample)
end

defimpl TypeClass.Property.Generator, for: Integer do
  def generate(_, _ \\ nil), do: :rand.uniform(1000) * Enum.random([1, 1, 1, -1])
end

defimpl TypeClass.Property.Generator, for: Float do
  def generate(_, _ \\ nil) do
    TypeClass.Property.Generator.generate(1) / TypeClass.Property.Generator.generate(1)
  end
end

defimpl TypeClass.Property.Generator, for: BitString do
  def generate(_, size \\ :rand.uniform(5)) do
    Stream.unfold("", &({&1, :rand.uniform(90)}))
    |> Stream.drop(1)
    |> Stream.take(size)
    |> Enum.to_list
    |> List.to_string
  end
end

defimpl TypeClass.Property.Generator, for: List do
  def generate(_, size \\ :rand.uniform(5)) do
    Stream.unfold(1, fn acc ->
      next =
        [0, 0, 0, 0, 0.0, 0.0, 0.0, 0.0, "", "", "", "", "", "", {}, [], %{}]
        |> Enum.random
        |> TypeClass.Property.Generator.generate

      {acc, next}
    end)
    |> Stream.drop(1)
    |> Stream.take(size)
    |> Enum.to_list
  end
end

defimpl TypeClass.Property.Generator, for: Tuple do
  def generate(_, size \\ :rand.uniform(5)) do
    []
    |> TypeClass.Property.Generator.generate
    |> List.to_tuple
  end
end

defimpl TypeClass.Property.Generator, for: Map do
  def generate(_, size \\ :rand.uniform(5)) do
    Stream.unfold({0, 1}, fn acc ->
      key = ["", 0] |> Enum.random |> TypeClass.Property.Generator.generate
      value =
        [0, 0, 0, 0, 0.0, 0.0, 0.0, 0.0, "", "", "", "", "", "", {}, [], %{}]
        |> Enum.random
        |> TypeClass.Property.Generator.generate

      next = {key, value}

      {acc, next}
    end)
    |> Stream.drop(1)
    |> Stream.take(size)
    |> Enum.to_list
    |> Enum.into(%{})
  end
end
