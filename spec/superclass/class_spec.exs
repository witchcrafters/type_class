defmodule Superclass.ClassSpec do
  import Superclass.Class
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
      |> to(eql [Superclass.ClassSpec.MyOtherClass, Superclass.ClassSpec.MyClass])
    end
  end

  describe "protocol" do
    defclass Functor do
      where do
        # @spec fmap(any, fun) :: any
        def fmap(enum, fun)
      end
    end

    defimpl Functor.Protocol, for: List do
      def fmap(enum, fun), do: Enum.map(enum, fun)
    end

    describe "underlying protocol" do
      it "is fmappable" do
        expect(Functor.Protocol.fmap([1,2,3], fn x -> x + 1 end)) |> to(eql [2,3,4])
      end
    end

    describe "unified API (reexport)" do
      it "is fmappable" do
        expect(Functor.fmap([1,2,3], fn x -> x + 1 end)) |> to(eql [2,3,4])
      end
    end
  end
end
