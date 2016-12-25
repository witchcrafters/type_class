defmodule TypeClass.ClassSpec do
  import TypeClass
  use ESpec

  defmodule MyModule do
    def plus_five(int), do: int + 5
  end

  defclass MyClass do
    def plus_five(int), do: int + 5
  end

  defclass MyOtherClass do
    def times_ten(int), do: int * 10
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
    end

    it "has a dependency" do
      require DependencyClass

      expect(DependencyClass.__dependencies__)
      |> to(eql [TypeClass.ClassSpec.MyOtherClass, TypeClass.ClassSpec.MyClass])
    end
  end

  describe "protocol" do
    defclass Functor do
      where do
        def fmap(enum, fun)
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
        use Functor, class: :alias, as: Functor
        expect(Functor.fmap([1,2,3], fn x -> x + 1 end)) |> to(eql [2,3,4])
      end
    end
  end

  describe "definst" do
    defclass Semigroup do
      where do
        def concat(a, b)
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
    end

    definst Monoid, for: List do
      def empty(_), do: []
    end
  end

  # describe "classic case" do
  #   defclass Functor do
  #     where do
  #       def map(collection, fun)
  #     end
  #   end

  #   defclass Apply do
  #     extend Functor

  #     where do
  #       def ap(collection, fun)
  #     end
  #   end

  #   defclass Applicative do
  #     extend Apply

  #     where do
  #       def of(val, ex)
  #     end

  #     defdelegate wrap(value, representative), to: Proto
  #   end

  #   defclass Chain do
  #     extend Apply

  #     where do
  #       def chain(wrapped, chaining_fun)
  #     end
  #   end

  #   defclass Monad do
  #     extend Applicative
  #     extend Chain

  #     where do
  #     end
  #   end
  # end
end
