defmodule TypeClass.Class do

  defmacro __using__(_) do
    require unquote(__MODULE__)
    import unquote(__MODULE__)
  end

  defmacro defclass(class_name, do: body) do
    use TypeClass.Class.Dependancy

    quote do
      Dependancy.set_up
      Operator.set_up
      Property.set_up
      Protocol.set_up

      body

      Dependancy.run
      Operator.run
      Property.run
      Protocol.run

      defmacro __using__(:class) do
        require class_name
        import class_name

        use_dependencies
      end
    end
  end
end

defclass Witchcraft.Monoid do
  @depend Witchcraft.Semigroup

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
  @where identity(any) :: any

  # Must contain at least one law
  @property reflexivity(a), do: a == a
  @property symmetry(a, b), do: equal?(a, b) == equal?(b, a)
  @property transitivity(a, b, c), do: equal?(a, b) && equal?(b, c) && equal?(a, c)
end
