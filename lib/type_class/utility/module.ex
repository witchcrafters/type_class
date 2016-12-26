defmodule TypeClass.Utility.Module do
  @moduledoc "Naming convention helpers to help follow TypeClass conventions"

  @doc ~S"""
  Generate the module name for the protocol portion of the class.
  Does not nest `Protocol`s.

  ## Examples

  iex> MyClass.Awesome |> to_protocol
  MyClass.Awesome.Protocol

  iex> MyClass.Awesome.Protocol |> to_protocol
  MyClass.Awesome.Protocol

  """
  @spec to_protocol(module) :: module
  def to_protocol(base_module), do: to_submodule(base_module, "Protocol")

  @doc ~S"""
  Generate the module name for the protocol portion of the class.
  Does not nest `Protocol`s.

  ## Examples

  iex> MyClass.Awesome |> to_property
  MyClass.Awesome.Property

  iex> MyClass.Awesome.Property |> to_property
  MyClass.Awesome.Property

  """
  @spec to_property(module) :: module
  def to_property(base_module), do: to_submodule(base_module, "Property")

  @doc ~S"""
  Generate a submodule name. If the module already ends in the
  requested submodule, it will return the module name unchanged.

  ## Examples

  iex> MyModule.Awesome |> to_submodule(Submodule)
  MyModule.Awesome.Submodule

  iex> MyModule.Awesome |> to_submodule("Submodule")
  MyModule.Awesome.Submodule

  iex> MyModule.Awesome.Submodule |> to_submodule(Submodule)
  MyModule.Awesome.Submodule

  """
  @spec to_submodule(module, String.t | module) :: module
  def to_submodule(base_module, child_name) when is_bitstring(child_name) do
    base_module
    |> Module.split
    |> List.last
    |> case do
         ^child_name -> base_module
         _           -> Module.concat([base_module, child_name])
       end
  end

  def to_submodule(base_module, child_module) do
    child_module
    |> Module.split
    |> Quark.flip(&to_submodule/2).(base_module)
  end

  def get_functions(module) do
    module.__info__(:functions)
    |> Enum.into(%{})
    |> Map.drop(~w(__protocol__ impl_for impl_for! __builtin__ __derive__ __ensure_defimpl__ __functions_spec__ __impl__ __spec__? assert_impl! assert_protocol! consolidate consolidated? extract_impls extract_protocols)a)
  end

  def append(parent_module, submodule) do
    parent_module
    |> Module.split
    |> fn modules -> modules ++ List.wrap(submodule) end.()
    |> Module.concat
  end

  def dispatch_delegate(fun_name, arity, module) do
    args =
      Stream.unfold(96, fn char ->
        next = char + 1
        {
          {List.to_atom([next]), [], Elixir},
          next
        }
      end)
      |> Enum.take(arity)

    quote do
      # IO.puts (inspect(unquote(fun_name)) <> inspect(unquote(args)))
      # def unquote(fun_name)(unquote_splicing(args)) do
      #   apply(Proto, unquote(fun_name), unquote(args))
      # end
      defdelegate unquote(fun_name)(unquote_splicing(args)), to: unquote(module)
    end
  end

  def reexport(module_ast) do
    {module, _} = Code.eval_quoted(module_ast)
    case Code.ensure_loaded(module) do
      {:error, :nofile} -> nil

      {:module, _module} ->
        for {fun_name, arity} <- get_functions(module) do
          dispatch_delegate(fun_name, arity, module)
        end
    end
  end

  def try_import(module_ast) do
    {module, _} = Code.eval_quoted(module_ast)
    case Code.ensure_loaded(module) do
      {:error, :nofile} ->
        nil

      {:module, _module} ->
        IO.puts "here"
        quote do: import unquote(module_ast)
    end
  end
end
