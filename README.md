![](./brand/logo.png)

[![Build Status](https://travis-ci.org/expede/type_class.svg?branch=master)](https://travis-ci.org/expede/type_class) [![Inline docs](http://inch-ci.org/github/expede/type_class.svg?branch=master)](http://inch-ci.org/github/expede/type_class) [![Deps Status](https://beta.hexfaktor.org/badge/all/github/expede/type_class.svg)](https://beta.hexfaktor.org/github/expede/type_class) [![hex.pm version](https://img.shields.io/hexpm/v/type_class.svg?style=flat)](https://hex.pm/packages/type_class) [![API Docs](https://img.shields.io/badge/api-docs-yellow.svg?style=flat)](http://hexdocs.pm/type_class/) [![license](https://img.shields.io/github/license/mashape/apistatus.svg?maxAge=2592000)](https://github.com/expede/type_class/blob/master/LICENSE)

`TypeClass` brings (semi-)[principled](http://degoes.net/articles/principled-typeclasses) [type classes](https://en.wikibooks.org/wiki/Haskell/Classes_and_types) to Elixir

# Quick Start

```
def deps do
  [{:type_class, "~> 0.1"}]
end
```

# NOTE!
This is in extremely early stages! _Nothing_ works yet! Barely more than a sketch of an idea.

# Example

```elixir
defclass Algebra.Monoid do
  @moduledoc "Monoid docs here"

  extend Algebra.Setoid
  extend Algebra.Semigroup

  defmacro __using__(_) do
    quote do
      require unquote(__MODULE__)
      import  unquote(__MODULE__)

      use_dependencies
    end
  end

  where do
    @doc "Return the 'identity' or 'empty' element of the monoid"
    @operator ^
    identity(any) :: any
  end

  defproperty left_identity(monoid_a) do
    monoid == monoid_a <> identity(monoid_a)
  end

  defproperty right_identity(monoid_a) do
    monoid == identity(monoid_a) <> monoid_a
  end

  @operator ^^^
  def append_id(a), do: identity(a) <> a
end

definstance Algebra.Monoid, for: List do
  def identity(_list), do: []
end
```

The rough equivalent in Haskell

```haskell
module Algebra.Monoid where

class (Setoid a, Semigroup a) => Monoid a where
  identity :: a -> a

  -- not actually needed in this case; just here for illustration
  append_id :: a -> a
  append_id a = identity a `append` a

instance Monoid [a] where
  identity _ = []
```
