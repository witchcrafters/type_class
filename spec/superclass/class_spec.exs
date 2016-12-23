defmodule Superclass.ClassSpec do
  use ESpec
  use Superclass.Class

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
end
