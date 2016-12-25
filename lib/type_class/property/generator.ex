defprotocol TypeClass.Property.Generator do
  def generate(sample)
end

defimpl TypeClass.Property.Generator, for: Integer do
  def generate(_), do: :rand.uniform(1000) * Enum.random([1, -1])
end

defimpl TypeClass.Property.Generator, for: Float do
  def generate(_) do
    TypeClass.Property.Generator.generate(1) / TypeClass.Property.Generator.generate(1)
  end
end

defimpl TypeClass.Property.Generator, for: String do
  def generate(_) do
    Stream.unfold([], fn acc ->
      next = :rand.uniform(90)
      {next, [next | acc]}
    end)
    |> Enum.take(:rand.uniform(100))
    |> to_string
  end
end

defimpl TypeClass.Property.Generator, for: List do
  def generate(_) do
    Stream.unfold([], fn acc ->
      next =
        [0, 0.1, "a", {}, [], %{}]
        |> Enum.random
        |> TypeClass.Property.Generator.generate

      {acc, [next | acc]}
    end)
    |> Enum.take(:rand.uniform(1000))
  end
end

defimpl TypeClass.Property.Generator, for: Tuple do
  def generate(_), do: [] |> TypeClass.Property.Generator.generate |> List.to_tuple
end

defimpl TypeClass.Property.Generator, for: Map do
  def generate(_) do
    Stream.unfold([], fn acc ->
      key = ["", 0] |> Enum.random |> TypeClass.Property.Generator.generate
      value = ["", 0, 0.0, [], %{}] |> Enum.random |> TypeClass.Property.Generator.generate
      next = {key, value}

      {acc, [next | acc]}
    end)
    |> Enum.take(:rand.uniform(100))
    |> Enum.into(%{})
  end
end
