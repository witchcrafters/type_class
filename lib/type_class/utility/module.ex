defmodule TypeClass.Utility.Module do
  @moduledoc "Naming convention helpers to help follow TypeClass conventions"

  @type ast :: tuple()

  @doc ~S"""
  Generate the module name for the protocol portion of the class.
  Does not nest `Protocol`s.

  ## Examples

      iex> to_protocol MyClass.Awesome
      MyClass.Awesome.Protocol

      iex> to_protocol MyClass.Awesome.Protocol
      MyClass.Awesome.Protocol

  """
  @spec to_protocol(module()) :: module()
  def to_protocol(base_module), do: to_submodule(base_module, "Protocol")

  @doc ~S"""
  Generate the module name for the protocol portion of the class.
  Does not nest `Protocol`s.

  ## Examples

      iex> to_property MyClass.Awesome
      MyClass.Awesome.Property

      iex> to_property MyClass.Awesome.Property
      MyClass.Awesome.roperty

  """
  @spec to_property(module()) :: module()
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
  @spec to_submodule(module(), String.t() | module()) :: module()
  def to_submodule(base_module, child_name) when is_bitstring(child_name) do
    base_module
    |> Module.split()
    |> List.last()
    |> case do
      ^child_name -> base_module
      _ -> Module.concat([base_module, child_name])
    end
  end

  def to_submodule(base_module, child_module) do
    to_submodule(base_module, Module.split(child_module))
  end

  def get_functions(module) do
    module.__info__(:functions)
    |> Enum.into(%{})
    |> Map.drop([
      :__protocol__,
      :impl_for,
      :impl_for!,
      :__builtin__,
      :__derive__,
      :__ensure_defimpl__,
      :__functions_spec__,
      :__impl__,
      :__spec__?,
      :assert_impl!,
      :assert_protocol!,
      :consolidate,
      :consolidated?,
      :extract_impls,
      :extract_protocols
    ])
  end

  def append(parent_module, submodule) do
    parent_module
    |> Module.split()
    |> (fn modules -> modules ++ List.wrap(submodule) end).()
    |> Module.concat()
  end
end
