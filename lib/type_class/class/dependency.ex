defmodule TypeClass.Class.Dependency do

  use TypeClass.Utility.Attribute
  use Quark

  defmacro __using__(_) do
    quote do
      alias   unquote(__MODULE__)
      require unquote(__MODULE__)

      unquote(__MODULE__).set_up
    end
  end

  @keyword :extend

  defmacro set_up do
    quote do: Attribute.register(unquote(@keyword), accumulate: true)
  end

  defmacro extend(parent_class) do
    quote do
      use unquote(parent_class)
      Attribute.set(unquote(@keyword), as: unquote(parent_class))
    end
  end

  defmacro run do
    quote do
      create_dependencies_meta
      create_use_dependencies
    end
  end

  defmacro create_dependencies_meta do
    quote do
      def __DEPENDENCIES__ do
        __MODULE__
        |> Attribute.get(unquote(@keyword))
        |> Enum.map(Utility.Module.to_protocol <~> Protocol.assert_impl!)
      end
    end
  end

  defmacro create_use_dependencies do
    quote do
      __DEPENDENCIES__
      |> Enum.map(&(Kernel.use(&1, :class)))
      |> unquote_splicing
    end
  end
end
