defmodule TypeClass.Class do

  defmacro __using__(_) do
    require unquote(__MODULE__)
    import unquote(__MODULE__)

    use Operator
  end

  defmacro defclass(class_name, do: body) do
    quote do
      defmacro __using__(:class) do
        require unquote(class_name)
        import  unquote(class_name)
      end

      TypeClass.Class.set_up
      unquote(body)
      TypeClass.Class.run
    end
  end

  defmacro set_up do
    Dependancy.use
    # Property.use
    Protocol.use
  end

  defmacro run do
    Dependancy.run
    # Property.run
  end
end
