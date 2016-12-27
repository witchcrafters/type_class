defmodule TypeClassSpec do
  import TypeClass
  use ESpec

  defmodule MyModule do
    def plus_five(int), do: int + 5

    properties do
      def foo(_), do: true
    end
  end

  defclass MyClass do
    def plus_five(int), do: int + 5

    properties do
      def foo(_), do: true
    end
  end

  defclass MyOtherClass do
    def times_ten(int), do: int * 10

    properties do
      def foo(_), do: true
    end
  end

  describe "moduleness" do
    it "is an alias for defmodule" do
      expect(MyClass.plus_five(42)) |> to(eql MyModule.plus_five(42))
    end
  end

  describe "dependencies" do
    defclass DependencyClass do
      extend MyClass
      extend MyOtherClass

      def half(int), do: int / 2

      properties do
        def foo(_), do: true
      end
    end

    it "has a dependency" do
      require DependencyClass

      expect(DependencyClass.__dependencies__)
      |> to(eql [TypeClassSpec.MyOtherClass, TypeClassSpec.MyClass])
    end
  end

  describe "protocol" do
    defclass Functor do
      where do
        def fmap(enum, fun)
      end

      properties do
        def foo(_), do: true
      end
    end

    definst Functor, for: List do
      def fmap(enum, fun), do: Enum.map(enum, fun)
    end

    describe "underlying protocol" do
      it "is fmappable" do
        expect(Functor.Proto.fmap([1,2,3], fn x -> x + 1 end)) |> to(eql [2,3,4])
      end
    end

    describe "unified API (reexport)" do
      it "is fmappable" do
        alias Functor
        expect(Functor.fmap([1,2,3], fn x -> x + 1 end)) |> to(eql [2,3,4])
      end
    end
  end

  describe "definst" do
    defclass Semigroup do
      where do
        def concat(a, b)
      end

      properties do
        def associative(data) do
          a = generate(data)
          b = generate(data)
          c = generate(data)

          left  = a |> Semigroup.concat(b) |> Semigroup.concat(c)
          right = Semigroup.concat(a, Semigroup.concat(b, c))

          left == right
        end
      end
    end

    definst Semigroup, for: List do
      def concat(a, b), do: a ++ b
    end

    defclass Monoid do
      extend Semigroup

      where do
        def empty(sample)
      end

      properties do
        def left_identity(data) do
          a = generate(data)
          Semigroup.concat(Monoid.empty(a), a) == a
        end

        def right_identity(data) do
          a = generate(data)
          Semigroup.concat(a, Monoid.empty(a)) == a
        end
      end
    end

    definst Monoid, for: List do
      def empty(_), do: []
    end
  end

  describe "classic case compiles" do
    defclass FunctorTwo do
      where do
        def map(collection, fun)
      end

      properties do
        def foo(_), do: true
      end
    end

    defclass Apply do
      extend FunctorTwo

      where do
        def ap(collection, fun)
      end

      properties do
        def foo(_), do: true
      end
    end

    defclass Applicative do
      extend Apply

      where do
        def of(val, ex)
      end

      defdelegate wrap(value, representative), to: Proto

      properties do
        def foo(_), do: true
      end
    end

    defclass Chain do
      extend Apply

      where do
        def chain(wrapped, chaining_fun)
      end

      properties do
        def foo(_), do: true
      end
    end

    defclass Monad do
      extend Applicative
      extend Chain

      properties do
        def foo(_), do: true
      end
    end
  end
end
