defmodule TypeClass.Instance do
  # @moduledoc ~S"""
  # """

  # defmacro __using__(_) do
  #   require unquote(__MODULE__)
  #   import unquote(__MODULE__)
  # end

  # defmacro definstance(class_name, for: datatype, do: body) do
  #   quote do
  #     target = unquote(datatype)

  #     Enum.reduce(class_name.Metadata.class_constraints, true, fn(constraint, validity) ->
  #       validity && exists?(constraint.target)
  #     end)

  #     Enum.each(class_name.Property.all, run_prop)
  #   end
  # end
end
