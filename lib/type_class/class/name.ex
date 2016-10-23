defmodule TypeClass.Class.Name do
  @moduledoc "Naming convention helpers to help follow TypeClass conventions"

  @doc ~S"""
  Generate the module name for the protocol portion of the class.
  Does not nest `Protocol`s.

  ## Examples

      iex> TypeClass.Class.Name.protocol(MyClass.Awesome)
      MyClass.Awesome.Protocol

      iex> TypeClass.Class.Name.protocol(MyClass.Awesome.Protocol)
      MyClass.Awesome.Protocol

  """
  @spec to_protocol(module) :: module
  def to_protocol(base_module) do
    base_module
    |> Module.split
    |> List.last
    |> case do
         "Protocol" -> base_module
         _          -> Module.concat([base_module, "Protocol"])
       end
  end
end
