defmodule TypeClass.Class do

  defmacro __using__(_) do
    require unquote(__MODULE__)
    import unquote(__MODULE__)

    use Operator
  end

  defmacro defclass(class_name, do: body) do
    use TypeClass.Class.Dependancy

    quote do
      set_up
      body
      run

      defmacro __using__(:class) do
        require class_name
        import class_name
      end
    end
  end

  defmacro set_up do
    Dependancy.use
    # Property.use
    # Protocol.use
  end

  defmacro run do
    Dependancy.run
    # Property.run
    # Protocol.run
  end
end
