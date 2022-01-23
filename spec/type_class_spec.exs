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
      expect(MyClass.plus_five(42)) |> to(eql(MyModule.plus_five(42)))
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

      expect(DependencyClass.__dependencies__())
      |> to(eql([TypeClassSpec.MyOtherClass, TypeClassSpec.MyClass]))
    end

    describe "without `where`" do
      defclass Adder do
        where do
          def plus_one(a)
        end

        properties do
          def pass(_), do: true
        end
      end

      defclass MoreProps do
        extend Adder

        properties do
          def yep(a) do
            equal?(a, a)
          end
        end
      end

      it "compiles without an explicit `where` block" do
        # Prep
        definst Adder, for: Integer do
          def plus_one(a), do: a + 5
        end

        # Test
        definst MoreProps, for: Integer
      end
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
        expect(Functor.Proto.List.fmap([1, 2, 3], fn x -> x + 1 end)) |> to(eql([2, 3, 4]))
      end
    end

    describe "unified API (reexport)" do
      it "is fmappable" do
        expect(Functor.fmap([1, 2, 3], fn x -> x + 1 end)) |> to(eql([2, 3, 4]))
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

          left = a |> Semigroup.concat(b) |> Semigroup.concat(c)
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

  describe "force type class" do
    defclass Fail do
      @force_type_class true

      where do
        def nonsense(goes_here)
      end

      properties do
        def fail(_), do: false
      end
    end

    definst Fail, for: Integer do
      def nonsense(_), do: 1
    end
  end

  describe "force instance" do
    defclass GoodClassBadInst do
      where do
        def my_div(num_a, num_b)
      end

      properties do
        def usually_good_but_hard_for_floats(data) do
          a = generate(data)
          # `==` so that we force the floats to disagree
          GoodClassBadInst.my_div(a * a, a) == a
        end
      end
    end

    definst GoodClassBadInst, for: Integer do
      def my_div(int_a, int_b), do: int_a / int_b
    end

    definst GoodClassBadInst, for: Float do
      @force_type_instance true
      def my_div(float_a, float_b), do: float_a / float_b
    end
  end

  describe "custom generator" do
    defclass Only2Tuple do
      where do
        def second(tuple)
      end

      properties do
        def limited(data) do
          size = data |> generate() |> tuple_size()
          size == 2
        end
      end
    end

    definst Only2Tuple, for: Tuple do
      custom_generator(a) do
        {:always_two, a}
      end

      def second({_a, b}), do: b
    end
  end
end
