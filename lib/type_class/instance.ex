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

  alias TypeClass.Utility

  defmacro __using__(_) do
    quote do
      require unquote(__MODULE__)
      alias   unquote(__MODULE__)
    end
  end

  defmacro definstance(class, for: type, do: body) do
    quote do
      defimpl(Utility.Module.to_protocol(unquote(class)), for: unquote(type)) do
        use TypeClass.Property.DataGenerator
        unquote do: body
      end
    end
  end
end
