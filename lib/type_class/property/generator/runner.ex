defmodule TypeClass.Property.Generator.Runner do
  @spec generate(Module) :: [any]
  def generate(class) do
    Stream.unfold([], fn acc ->
      next = class.generator
      {acc ++ next, next}
    end)
  end

  def generate(class, times) do
    generate(class) |> Enum.take(times)
  end
end
