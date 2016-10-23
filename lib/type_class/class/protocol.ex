defmodule TypeClass.Class.Protocol do

  defmacro __using__(_) do
    quote do
      require unquote(__MODULE__)
      import  unquote(__MODULE__), only: [where: 1]
    end
  end

  defmacro where(do: fun_specs) do
    quote do
      defprotocol TypeClass.Class.Name.to_protocol(unquote(__MODULE__)) do
        @moduledoc ~s"""
        Protocol for the `#{unquote(__MODULE__)}` type class

        For this type class's API, please refer to `#{unquote(__MODULE__)}`
        """

        unquote(fun_specs)
      end
    end
  end
end
