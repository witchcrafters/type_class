defmodule Superclass do

  alias Superclass.Class

  use Superclass.Instance
  use Superclass.Property
  use Superclass.Property.DataGenerator

  defmacro __using__(_) do
    quote do
      import unquote(__MODULE__)
      require Superclass.Class
    end
  end

  defmacro defclass(name, do: body) do
    quote do: Class.defclass(unquote(name), do: unquote(body))
  end

  defmacro definstance(class, for: type, do: body) do
    quote do
      Instance.definstance(unquote(class), for: unquote(type), do: unquote(body))
    end
  end

  # defmacro defproperty(fun_head, opts), to: Superclass.Property

  defmacro defgenerator(unique_name, do: body) do
    quote do: DataGenerator.defgenerator(unquote(unique_name), do: unquote(body))
  end
end
