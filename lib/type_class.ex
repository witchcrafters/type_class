defmodule TypeClass do

  defdelegate defclass(name, do: body), to: TypeClass.Class
  defdelegate definstance(class, for: type, do: body), to: TypeClass.Instance

  defdelegate defproperty(fun_head, do: body),  to: TypeClass.Property
  defdelegate defgenerator(name, do: body), to: TypeClass.Property.Generator
end
