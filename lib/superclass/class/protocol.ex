defmodule Superclass.Class.Protocol do
  @moduledoc ~S"""
  The protocol helpers for defining the critical functions of a type class
  """

  alias Superclass.Utility
  use Superclass.Utility.Attribute

  defmacro __using__(_) do
    quote do
      require unquote(__MODULE__)
      import  unquote(__MODULE__), only: [where: 1]
    end
  end

  defmacro where(do: fun_specs) do
    ast = Macro.escape(fun_specs)
    quote do: @class_where unquote(ast)
  end

  defmacro set_up do
    quote do: Attribute.register(:class_where, accumulate: true)
  end

  defmacro run do
    quote do
      wheres = all_wheres
      unify_top_level_api(wheres)
      generate_protocol(wheres, for: unquote(__MODULE__))
    end
  end

  defmacro all_wheres do
    quote do
      [__DATA_GENERATOR__(name, do: body) | @class_where]
      |> List.flatten
    end
  end

  defmacro unify_top_level_api(wheres) do
    quote do: unified_wheres |> transform_ast_delegate |> unquote
  end

  defmacro generate_protocol(wheres, for: module) do
    quote do
      defprotocol Utility.Module.to_protocol(unquote(module)) do
        @moduledoc moduledoc_text(unquote(module))

        unquote(wheres)
      end
    end
  end

  defmacro transform_ast_delegate(ast) do
    {fun_sym, ctx, args} = ast

    quote do
      case unquote(fun_sym) do
        :__block__ ->
          {
            :__block__,
            unquote(ctx),
            Enum.map(unquote(args), &transform_ast_delegate/1)
          }

        :@  ->
          unquote(ast)

        fun ->
          protocol = Utility.Module.to_protocol(__MODULE__)
          defdelegate(unquote(ast), to: protocol, as: unquote(fun_sym))
      end
    end
  end

  def moduledoc_text(module) do
    ~s"""
    Protocol for the `#{module}` type class

    For this type class's API, please refer to `#{module}`
    """
  end
end
