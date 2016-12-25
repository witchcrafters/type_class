defmodule TypeClass.Property.Generator do
  @callback __generator__() :: any

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
