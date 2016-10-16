defmodule TypeClass.Class.Name do
  def new(base), do: Module.concat([base, "Protocol"])
end
