defmodule TypeClass.Class.Dependancy do

  defmacro __using__(_) do
    quote do
      alias   TypeClass.Class
      alias   unquote(__MODULE__)
      require unquote(__MODULE__)

      unquote(__MODULE__).set_up
    end
  end

  defmacro set_up do
    quote do
      Module.register_attribute __MODULE__, :depend, accumulate: true
    end
  end

  defmacro run do
    quote do
      def __DEPENDANCIES__ do
        unquote do
          use Quark

          __MODULE__
          |> Module.get_attribute(:extend)
          |> Enum.map(Class.Name.to_protocol <~> Class.Protocol.assert_impl!)
        end
      end
    end
  end

  defmacro use_dependancies do
    quote do
      __DEPENDANCIES__
      |> Enum.map(&(Kernel.use &1, :class)
      |> unquote_splicing
    end
  end
end
