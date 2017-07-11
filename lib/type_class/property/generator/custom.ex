defmodule TypeClass.Property.Generator.Custom do
  @moduledoc "Internal representation of a custom generator"

  alias __MODULE__

  @type t :: %TypeClass.Property.Generator.Custom{generator: fun()}
  defstruct generator: &Quark.id/1

  @doc "Define a hidden `__cutsom_generator__/1` function"
  defmacro custom_generator(arg, do: body) do
    quote do
      @doc false
      def __custom_generator__ do
        %TypeClass.Property.Generator.Custom{
          generator: fn unquote(arg) ->
            unquote(body)
          end
        }
      end
    end
  end
end
