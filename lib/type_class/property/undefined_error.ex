defmodule TypeClass.Property.UndefinedError do
  @moduledoc ~S"""
  Warning if a type class is missing properties.
  Properties are required for all type classes.
  """

  @type t :: %TypeClass.Property.UndefinedError{
          type_class: module(),
          message: String.t()
        }

  defexception message: "Property not defined for type", type_class: nil

  @doc ~S"""
  Convenience constructor

  ## Examples

      iex> TypeClass.Property.UndefinedError.new(CoolClass)
      %TypeClass.Property.UndefinedError{
        type_class: CoolClass,
        message: ~S"
        CoolClass has not defined any properties, but they are required.

        See `TypeClass.properties/1` for more
        "
      }

  """
  @spec new(module()) :: t()
  def new(class) do
    %TypeClass.Property.UndefinedError{
      type_class: class,
      message: """
      #{class} has not defined any properties, but they are required.

      See `TypeClass.properties/1` for more
      """
    }
  end
end
