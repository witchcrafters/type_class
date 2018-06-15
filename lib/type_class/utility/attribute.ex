defmodule TypeClass.Utility.Attribute do
  @moduledoc "Helpers to module attributes"

  @doc "Set up a compile time attribute key for getting and setting"
  @spec register(atom(), []) :: no_return()
  defmacro register(attribute, opts \\ []) do
    quote bind_quoted: [attribute: attribute, opts: opts] do
      Module.register_attribute(__MODULE__, attribute, opts)
    end
  end

  @doc "Set a compile-time module attribute"
  @spec set(atom(), as: atom()) :: no_return()
  defmacro set(value, as: attribute) do
    quote bind_quoted: [attribute: attribute, value: value] do
      Module.put_attribute(__MODULE__, attribute, value)
    end
  end

  @doc "Retrieve the compile-time value stored at the specified attribute key"
  @spec get(atom()) :: any()
  defmacro get(attribute) do
    quote do: Module.get_attribute(__MODULE__, unquote(attribute))
  end
end
