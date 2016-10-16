defmodule Classy.Class do

  defmacro __using__(_) do
    require unquote(__MODULE__)
    import unquote(__MODULE__)
  end

  defmacro defclass(class_name, do: body) do
    use Classy.Class.Dependency

    quote do
      Dependancy.set_up


      defmodule unquote(class_name) do
        defmacro __using__(_) do
          import Kernel, except: overrides
          import class_name
        end

        import Kernel, except: [==: 2] # Manual, since body gets inlined
        def __dependencies__, do: [Witchcraft.Semigroup]

        defdelegate equal?(a, b), to: Protocol

        def unequal?(a, b), do: !equal?(a, b)

        defdelegate a == b, to: equal?
        defdelegate a != b, to: unequal?

        defmodule Property do
          def all, do: [&reflexivity/1, &symmetry/2, &transitivity/3]

          def reflexivity(a), do: a == a
          def symmetry(a, b), do: equal?(a, b) == equal?(b, a)
          def transitivity(a, b, c), do: equal?(a, b) && equal?(b, c) && equal?(a, c)
        end

        defprotocol Protocol do
          def equal?(a, b)
        end
      end

      Dependancy.run
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
