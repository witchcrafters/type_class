defmodule TypeClass.Property.Undefined do
  @moduledoc ~S"""
  Warning if a type class is missing properties.
  Properties are required for all type classes.
  """

  defexception message: @base, type_class: nil

  def new(class) do
    %TypeClass.Property.Undefined{
      type_class: class,
      message: """
      #{class} has not defined any properties, but they are required.
      See `TypeClass.properties/1` for more
      """
    }
  end
end
