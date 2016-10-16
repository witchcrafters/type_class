defmodule TypeClass.Class.Protocol do

  defmacro set_up do
    quote do
      Module.register_attribute __MODULE__, :where, accumulate: true
    end
  end

  defmacro run do
    quote do
      class_module = __MODULE__
      protocol_module = Module.concat([class_module, Protocol])

      funs = Module.get_attribute(class_module, :where)

      # SO MUCH PLACEHOLDER!

      defmodule protocol_module do
        Enum.each(funs, Protocol.def)
      end

      funs
      |> extract_names
      Enum.each(fn fun_name -> defdelegate(fun, to: protocol_module) end)
    end
  end
end
