defmodule TypeClass.Property.FailedCheck do
  @moduledoc "Information about a failed property check"

  @base "Failed type class property"
  defexception message: @base, datatype: nil, type_class: nil, property: nil

  def new(datatype, class, prop_name) do
    %TypeClass.Property.FailedCheck{
      type_class: class,
      property: prop_name,
      datatype: datatype,
      message: "#{datatype} does not conform to property #{class}.#{to_string(prop_name)}"
    }
  end
end
