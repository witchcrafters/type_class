defmodule TypeClass.Class.Dependancy do

  defmacro __using__(_) do
    quote do
      alias   TypeClass.Class
      alias   unquote(__MODULE__)
      require unquote(__MODULE__)

      unquote(__MODULE__).set_up
    end
  end

  @keyword :extend

  defmacro set_up do
    quote do
      Module.register_attribute __MODULE__, unquote(@keyword), accumulate: true
    end
  end

  defmacro run do
    quote do
      create_dependancies_meta
      create_use_dependancies
    end
  end

  defmacro create_dependancies_meta do
    quote do
      def __DEPENDANCIES__ do
        unquote do
          use Quark

          __MODULE__
          |> Module.get_attribute(unquote(@keyword))
          |> Enum.map(Class.Name.to_protocol <~> Class.Protocol.assert_impl!)
        end
      end
    end
  end

  defmacro create_use_dependancies do
    quote do
      __DEPENDANCIES__
      |> Enum.map(&(Kernel.use &1, :class)
      |> unquote_splicing
    end
  end
end
