defclass Algebra.Monoid do
  @moduledoc "Monoid docs here"

  extend Algebra.Setoid
  extend Algebra.Semigroup

  defmacro __using__(_) do
    quote do
      require unquote(__MODULE__)
      import  unquote(__MODULE__)

      use_dependencies
    end
  end

  where do
    @doc "Return the 'identity' or 'empty' element of the monoid"
    @operator ^
    identity(any) :: any
  end

  defproperty left_identity(monoid_a) do
    monoid == monoid_a <> identity(monoid_a)
  end

  defproperty right_identity(monoid_a) do
    monoid == identity(monoid_a) <> monoid_a
  end

  @operator ^^^
  def append_id(a), do: identity(a) <> a
end

definstance Algebra.Monoid, for: List do
  def identity(_list), do: []
end
