defmodule TypeClass.Class.Name do
  @moduledoc "Naming convention helpers to help follow TypeClass conventions"

  @type module :: atom

  @doc ~S"""
  Generate the module name for the protocol portion of the class

  ## Examples

      iex> TypeClass.Class.Name.protocol(MyClass.Awesome)
      MyClass.Awesome.Protocol

  """
  @spec to_protocol(module) :: module
  def to_protocol(class_base), do: Module.concat([class_base, "Protocol"])
end
