defmodule Superclass.ClassSpec do
  use Superclass
  use ESpec

  defclass Foo do
    def foo(a), do: a
  end

  it "is an alias for defmodule" do
    expect(Foo.foo(5)) |> to(eql 5)
  end
end