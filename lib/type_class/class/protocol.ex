defmodule TypeClass.Class.Protocol do
  @moduledoc ~S"""
  The protocol portion of a type class
  """

  use TypeClass.Util.Attribute

  @keyword :class_where

  defmacro __using__(_) do
    quote do
      require unquote(__MODULE__)
      import  unquote(__MODULE__), only: [where: 1]
    end
  end

  defmacro where(do: fun_specs) do
    ast = Macro.escape(fun_specs)
    quote do
      @where unquote(ast)
    end
  end

  defmacro set_up do
    quote do: Attribute.register(unquote(@keyword), accumulate: true)
  end

  defmacro run do
    quote do
      defprotocol TypeClass.Class.Name.to_protocol(unquote(__MODULE__)) do
        __MODULE__
        |> moduledoc
        |> Attribute.set(:moduledoc)

        Attribute.get(unquote(@keyword))
      end
    end
  end

  def moduledoc(module) do
    ~s"""
    Protocol for the `#{module}` type class

    For this type class's API, please refer to `#{module}`
    """
  end
end
