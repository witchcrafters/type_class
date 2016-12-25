defmodule TypeClass.Property.FailedCheck do
  @moduledoc "Information about a failed property check"

  @base "Failed type class property"
  defexception message: @base, datatype: nil, class: nil, property: nil

  def new(datatype, class, prop) do
    %TypeClass.Property.FailedCheck{
      typeclass: class,
      property:  prop_name,
      datatype:  datatype,
      message:   "#{datatype} does not confirm to property #{class}.#{prop}"
    }
  end
end
