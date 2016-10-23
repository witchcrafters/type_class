defmodule TypeClassTest do
  use ExUnit.Case

  doctest TypeClass

  test "the truth" do
    assert 1 + 1 == 2
  end
end

# REFERENCE PLAN
defclass Witchcraft.Monoid do
  @extend Witchcraft.Semigroup

  # Calls `use`, and adds to Witchcraft.Monoid.__dependencies__

  defmacro __using__(_) do
    quote do
      import unquote(__MODULE__)
      use_dependencies
    end
  end

  @operator &&&
    def append_id(a), do: identity <> a

  @operator ^
  where do
    identity(any) :: any
  end

  # Must contain at least one law
  @property reflexivity(a), do: a == a
  @property symmetry(a, b), do: equal?(a, b) == equal?(b, a)
  @property transitivity(a, b, c), do: equal?(a, b) && equal?(b, c) && equal?(a, c)
end

definstance Wicthcraft.Monoid, for: List do
  def identity(a), do: a

  property_generator :list_ints do
    Enum.reduce([], {0..:rand.uniform(10), [], fn(_, acc) -> [:rand.uniform(100) | acc] end)
    end
    end
