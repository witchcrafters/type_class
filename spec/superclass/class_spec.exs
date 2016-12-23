defmodule Superclass.ClassSpec do
  use Superclass
  use ESpec

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
