defmodule TypeClass.Property.Generator.Custom do
  @moduledoc "Internal representation of a custom generator"

  @type t :: %TypeClass.Property.Generator.Custom{generator: fun()}
  defstruct generator: nil

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
