defmodule Superclass.Class.Protocol do
  @moduledoc ~S"""
  The protocol helpers for defining the critical functions of a type class
  """

  alias Superclass.Utility
  use Superclass.Utility.Attribute

  defmacro __using__(_) do
    quote do
      import  unquote(__MODULE__)
    end
  end
end
