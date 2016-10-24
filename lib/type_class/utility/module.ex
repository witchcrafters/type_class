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
  def to_protocol(base_module) do: to_submodule(base_module, "Protocol")

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
  def to_property(base_module) do: to_submodule(base_module__, "Property")

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
    |> Quark.flip(to_submodule).(base_module)
  end
end
