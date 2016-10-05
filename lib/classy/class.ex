defmodule Classy.Class do

  defmacro __using__(_) do
    require unquote(__MODULE__)
    import unquote(__MODULE__)
  end

  defmacro defclass(class_name, do: body) do
    quote do
      overrides = []

      defmodule unquote(class_name) do
        defmacro __using__(_) do
          import Kernel, except: overrides
          import class_name
        end

        import Kernel, except: overrides

        defdelegate equal?(a, b), to: Protocol

        defdelegate unequal?(a, b), to: Function

        defdelegate a == b, to: Operator
        defdelegate a != b, to: Operator

        defmodule Metadata do
          def class_constraints, do: []
        end

        defmodule Function do
          def unequal?(a, b), do: !equal?(a, b)
        end

        defmodule Operator do
          defdelegate a == b, to: equal?
          defdelegate a != b, to: unequal?
        end

        defmodule Property do
          @behaviour Classy.Laws

          def all, do: [&reflexivity/1, &symmetry/2, &transitivity/3]

          def reflexivity(a), do: a == a
          def symmetry(a, b), do: equal?(a, b) == equal?(b, a)
          def transitivity(a, b, c), do: equal?(a, b) && equal?(b, c) && equal?(a, c)
        end

        defprotocol Protocol do
          def equal?(a, b)
        end
      end
    end
  end
end
