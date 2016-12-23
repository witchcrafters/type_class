defmodule Superclass.Utility.Module do
  @moduledoc "Naming convention helpers to help follow Superclass conventions"

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
    |> to_string
    |> Module.split
    |> Quark.flip(&to_submodule/2).(base_module)
  end

  defmacro reexport_all(module_name) do
    quote do
      module = unquote(module_name)

      Enum.map(module.__info__, fn {fun_name, arity} ->
        case arity do
          0 -> defdelegate fun_name(), to: module
          1 -> defdelegate fun_name(a), to: module
          2 -> defdelegate fun_name(a, b), to: module
          3 -> defdelegate fun_name(a, b, c), to: module
          4 -> defdelegate fun_name(a, b, c, d), to: module
          5 -> defdelegate fun_name(a, b, c, d, e), to: module
          6 -> defdelegate fun_name(a, b, c, d, e, f), to: module
          7 -> defdelegate fun_name(a, b, c, d, e, f, g), to: module
          8 -> defdelegate fun_name(a, b, c, d, e, f, g, h), to: module
          9 -> defdelegate fun_name(a, b, c, d, e, f, g, h, i), to: module
        end
      end)
    end
  end
end
