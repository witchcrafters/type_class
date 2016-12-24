defmodule TypeClass.Utility.Module do
  @moduledoc "Naming convention helpers to help follow TypeClass conventions"

  @doc ~S"""
  Generate the module name for the protocol portion of the class.
  Does not nest `Protocol`s.

  ## Examples

  iex> MyClass.Awesome |> to_protocol
  MyClass.Awesome.Protocol

  iex> MyClass.Awesome.Protocol |> to_protocol
  MyClass.Awesome.Protocol

  """
  @spec to_protocol(module) :: module
  def to_protocol(base_module), do: to_submodule(base_module, "Protocol")

  @doc ~S"""
  Generate the module name for the protocol portion of the class.
  Does not nest `Protocol`s.

  ## Examples

  iex> MyClass.Awesome |> to_property
  MyClass.Awesome.Property

  iex> MyClass.Awesome.Property |> to_property
  MyClass.Awesome.Property

  """
  @spec to_property(module) :: module
  def to_property(base_module), do: to_submodule(base_module, "Property")

  @doc ~S"""
  Generate a submodule name. If the module already ends in the
  requested submodule, it will return the module name unchanged.

  ## Examples

  iex> MyModule.Awesome |> to_submodule(Submodule)
  MyModule.Awesome.Submodule

  iex> MyModule.Awesome |> to_submodule("Submodule")
  MyModule.Awesome.Submodule

  iex> MyModule.Awesome.Submodule |> to_submodule(Submodule)
  MyModule.Awesome.Submodule

  """
  @spec to_submodule(module, String.t | module) :: module
  def to_submodule(base_module, child_name) when is_bitstring(child_name) do
    base_module
    |> Module.split
    |> List.last
    |> case do
         ^child_name -> base_module
         _           -> Module.concat([base_module, child_name])
       end
  end

  def to_submodule(base_module, child_module) do
    child_module
    |> Module.split
    |> Quark.flip(&to_submodule/2).(base_module)
  end

  defmacro reexport(module) do
    quote do
      import unquote(__MODULE__)

      for {fun_name, arity} <- get_functions(unquote module) do
        IO.puts "name: #{fun_name} , arity: #{arity}"
        TypeClass.Utility.Module.dispatch_delegate(fun_name, arity, unquote(module))
      end
    end
  end

  def get_functions(module) do
    module.__info__(:functions)
    |> Enum.into(%{})
    |> Map.drop(~w(__protocol__ impl_for impl_for! __builtin__ __derive__ __ensure_defimpl__ __functions_spec__ __impl__ __spec__? assert_impl! assert_protocol! consolidate consolidated? extract_impls extract_protocols)a)
  end

  def dispatch_delegate(fun_name, arity, module) do
    case arity do
      0 -> quote do: defdelegate unquote(fun_name)(), to: unquote(module)
      1 -> quote do: defdelegate unquote(fun_name)(a), to: unquote(module)
      2 -> quote do: defdelegate unquote(fun_name)(a, b), to: unquote(module)
      3 -> quote do: defdelegate unquote(fun_name)(a, b, c), to: unquote(module)
      4 -> quote do: defdelegate unquote(fun_name)(a, b, c, d), to: unquote(module)
      5 -> quote do: defdelegate unquote(fun_name)(a, b, c, d, e), to: unquote(module)
      6 -> quote do: defdelegate unquote(fun_name)(a, b, c, d, e, f), to: unquote(module)
      7 -> quote do: defdelegate unquote(fun_name)(a, b, c, d, e, f, g), to: unquote(module)
      8 -> quote do: defdelegate unquote(fun_name)(a, b, c, d, e, f, g, h), to: unquote(module)
      9 -> quote do: defdelegate unquote(fun_name)(a, b, c, d, e, f, g, h, i), to: unquote(module)
    end
  end
end
