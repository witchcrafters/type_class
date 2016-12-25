defmodule TypeClass.Utility.Attribute do

  defmacro get(attribute) do
    quote do: Module.get_attribute(__MODULE__, unquote(attribute))
  end

  defmacro set(value, as: attribute) do
    quote bind_quoted: [attribute: attribute, value: value] do
      Module.put_attribute(__MODULE__, attribute, value)
    end
  end

  defmacro register(attribute, opts \\ []) do
    quote bind_quoted: [attribute: attribute, opts: opts] do
      Module.register_attribute(__MODULE__, attribute, opts)
    end
  end
end
