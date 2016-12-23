defmodule Superclass.ClassSpec do
  use ESpec
  use Superclass.Class

  describe "moduleness" do
    defmodule MyModule do
      def plus_five(int), do: int + 5
    end

    defclass MyClass do
      def plus_five(int), do: int + 5
    end

    it "is an alias for defmodule" do
      expect(MyClass.plus_five(42)) |> to(eql MyModule.plus_five(42))
    end
  end

  describe "dependencies" do
    defclass MyOtherClass do
      extend MyClass

      def times_ten(int), do: int * 10
    end

    it "works" do
      expect(MyOtherClass.times_ten(2)) |> to(eql 20)
    end

    it "has a dependency" do
      require MyOtherClass
      expect(MyOtherClass.__dependencies__) |> to(eql [Superclass.ClassSpec.MyClass])
    end
  end
end
