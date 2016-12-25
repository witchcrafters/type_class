defmodule TypeClass.Property do
  alias __MODULE__
  use TypeClass.Utility.Attribute

  defmacro __using__(_) do
    quote do
      require unquote(__MODULE__)
      alias   unquote(__MODULE__)
    end
  end

  # defmacro defproperty(name, )

  @spec check_all([fun], [fun], pos_integer) :: :ok | Property.Error.t
  def check_all(properties, data_generators, times \\ 100) do
    # properties
    # |> Enum.each(fn prop ->
    #   # Enum.reduce(class.__PROPERTY)
    #   check(prop, times)
    # end)
  end

  @keyword :properties

  defmacro set_up do
    quote do: Attribute.register(unquote(@keyword), accumulate: true)
  end

  defmacro run do
    quote do
      unquote(@keyword)
      |> Attribute.get
      |> unquote(__MODULE__).merge_blocks
      |> fn ast ->
        __MODULE__
        |> Utility.Module.to_property
        |> defmodule(do: ast)
      end.()
    end
  end

  defmacro defproperty(fun_head, do: body) do
    {_fun_name, ctx, _args} = fun_head
    defun = {:def, ctx, [fun_head]}
    ast = Macro.escape({:__block__, ctx, [{:def, ctx, [fun_head, do: body]}]})

    quote do: Attribute.set(unquote(@keyword), unquote(ast))
  end

  defmacro properties(prop_block) do
    ast = Macro.escape(prop_block)
    quote do: Attribute.set(unquote(@keyword), unquote(ast))
  end

  def merge_blocks(block_asts) do
    block_asts
    |> Enum.reduce([], fn({:__block__, _ctx, body}, acc) -> acc ++ body end)
    |> fn merged_bodies -> {:__block__, [], merged_bodies} end.()
  end

end
