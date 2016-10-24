# Might need to be TypeClass.defclass Monoid do
defclass Monoid do
  @moduledoc "Monoid docs here"

  alias Quux
  use Bar

  extend Witchcraft.Semigroup
  extend Witchcraft.Foo

  defmacro __using__(_) do
    quote do
      require unquote(__MODULE__)
      import unquote(__MODULE__)

      use_dependencies
    end
  end

  @operator &&&
  def append_id(a), do: identity <> a

  where do
    @operator ^
    identity(any) :: any
  end

  properties do
    def reflexivity(a), do: a == a
    def symmetry(a, b), do: equal?(a, b) == equal?(b, a)
  end

  defproperty transitivity(a, b, c) do
    equal?(a, b) && equal?(b, c) && equal?(a, c)
  end
end
