defmodule TypeClass.Property.FailedCheckError do
  @moduledoc ~S"""
  Information about a failed property check

  ## Examples

      %TypeClass.Property.FailedCheckError{
        message:  "List does not conform to property CoolClass.associative",
        datatype: List,
        property: :associative,
        class:    CoolClass
      }

  """

  @type t :: %TypeClass.Property.FailedCheckError{
          message: String.t(),
          datatype: module(),
          type_class: module(),
          property: atom()
        }

  defexception message: "Failed type class property",
               datatype: nil,
               type_class: nil,
               property: nil

  @doc ~S"""
  Convenience constructor

  ## Examples

      iex> TypeClass.Property.FailedCheckError.new(List, CoolClass, :associative)
      %TypeClass.Property.FailedCheckError{
        message:  "List does not conform to property CoolClass.associative",
        datatype: List,
        property: :associative,
        class:    CoolClass
      }

  """
  @spec new(module(), module(), atom()) :: t()
  def new(datatype, class, prop_name) do
    %TypeClass.Property.FailedCheckError{
      type_class: class,
      property: prop_name,
      datatype: datatype,
      message: "#{datatype} does not conform to property #{class}.#{to_string(prop_name)}"
    }
  end
end
