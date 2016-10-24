defmodule TypeClass.Class.Property do

  use TypeClass.Utility.Attribute

  defmacro __using__(_) do
    quote do
      require unquote(__MODULE__)
      alias   unquote(__MODULE__)
    end
  end

  @keyword :properties

  defmacro set_up do
    quote do: Attribute.register(unquote(@keyword), accumulate: true)
  end

  defmacro run do
    quote do
      unquote(@keyword)
      |> Attribute.get
      |> merge_blocks
      |> fn ast ->
        __MODULE__
        |> Utility.Module.to_property
        |> defmodule(do: unquote(ast))
      end.()
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
