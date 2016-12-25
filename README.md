![](./brand/logo.png)

[![Build Status](https://travis-ci.org/expede/superclass.svg?branch=master)](https://travis-ci.org/expede/superclass) [![Inline docs](http://inch-ci.org/github/expede/superclass.svg?branch=master)](http://inch-ci.org/github/expede/superclass) [![Deps Status](https://beta.hexfaktor.org/badge/all/github/expede/superclass.svg)](https://beta.hexfaktor.org/github/expede/superclass) [![hex.pm version](https://img.shields.io/hexpm/v/superclass.svg?style=flat)](https://hex.pm/packages/superclass) [![API Docs](https://img.shields.io/badge/api-docs-yellow.svg?style=flat)](http://hexdocs.pm/superclass/) [![license](https://img.shields.io/github/license/mashape/apistatus.svg?maxAge=2592000)](https://github.com/expede/superclass/blob/master/LICENSE)

`TypeClass` brings (semi-)[principled](http://degoes.net/articles/principled-typelasses) [type classes](https://en.wikibooks.org/wiki/Haskell/Classes_and_types) to Elixir

# NOTE!
This is in extremely early stages! _Nothing_ works yet! Barely more than a sketch of an idea.

# Table of Contents

- [Quick Start](#quick-start)
- [Type Classes](#type-classes)
  - [`defclass` and `definst`](#defclass-and-definst)
  - [Hierarchy](#hierarchy)
  - [Principled](#principled)
- [Example](#example)
  - [TypeClass](#TypeClass)
  - [Haskell](#haskell)

# Quick Start

```elixir
def deps do
  [{:type_class, "~> 0.1"}]
end
```

# Type Classes
Type classes are not unlike protocols. They are essentially a mechanism for ad hoc polymorphism. However, doing extensive work with protocols can be cumbersome in Elixir. Even the standard library uses the confusingly named `Enumerator` protocol to support the `Enum` module. `TypeClass` attempts to hide many of the details to give you a single module interface.

## Condensed Style
To this end, `TypeClass` provides the `defclass` macro to handle generating all of the modules, submodules, and protocols.

`definstance` is very similar to `defimpl`, except that you don't need to pass it the actual protocol; you only pass it just the "top" class module. It will also automatically run a number of checks at compile time to help keep everything running as per the definition in `defclass` (more on that later)

## Hierarchical
Type classes can be hierarchical. The `extend` macro allows defining another class that your class depends on existing. A common example from Haskell and similar is how the monad instance must also be an applicative, which in turn must be a functor. `definstance` will check that the type you are implementing already has an implementation of the parent classes. Specifying multiple parents is totally okay, as this is superclassing, not subclassing like in an object oriented system.

## Principled
Type classes have the ability to be abused. For instance, in languages such as Haskell, a programmer can define an instance of `Monad a` that is not actually a monad. This can lead to confusing and unexpected behaviour. After all the purpose of protocols and type classes is so that we abstract some invariant behaviour over many data types.

At the core, type classes are about the _properties_ that enable its functions to work correctly. To emphasize that: _properties are the most important part of a type class_. Strictly speaking, for the compiler to enforce properties at compile time, it needs to have a lot of type-level information (ideally dependant types, GADTs, or very advanced static analysis). Elixir is dynamically typed, and has almost no type information at compile time.

`TypeClass` meets this challenge halfway: property testing. `definstance` will property test a small batch of examples on every data typed that the class is defined for _at compile time_. By default, it skips this check in production, runs a minimal set of cases in development, and runs a larger suite in the test environment. Property testing lets `TypeClass` check hundreds of specific examples very quickly, so while it doesn't give you a guarantee that your instance is correct, it does give you a high level of confidence.

[John De Goes](http://degoes.net) defines [principled type classes](http://degoes.net/articles/principled-typeclasses) as:

> Haskell-style. A baked-in notion of type classes in the overall style of Haskell, Purescript, Idris, etc.

`defclass` and `definstance` get us 99% of the way here. It's not as lightweight as in Haskell &c, but it's close (and much more succinct than what is available in `Kernel`)

> Lawful. First-class laws for type classes, which are enforced by the compiler.

As mentioned above, we meet laws/properties halfway with compile-time property tests.

> Hierarchical. A compiler-verified requirement that a subclass of a type class must have at least one more law than that type class.

`TypeClass` requires at least one property per class. You can build type class hierarchies with `extend`.

> Globally Unambiguous. Type class resolution that produces an error if there exists more than one instances which satisfies the constraints at the point where the compiler must choose an instance.

Elixir is dynamically typed, and so we cannot constrain functions at compile time. However, the point is well taken: rather than creating a renamed variant of a type so that you can have multiple instances (ex. `Monoid` can be integer addition or multiplication), extend the TypeClass and give it the additional properties that you're interested in for each case (ex. `AdditiveMonoid` and `MultiplicativeMonoid` extend `Monoid`).

> Abstractable. The ability to abstract over type classes themselves.

De Goes is referring here to abstracting over type holes. Elixir is dynamically typed, so this one doesn't apply to us.

# Example

## TypeClass

```elixir
defclass Algebra.Monoid do
  @moduledoc "Monoid docs here"

  extend Algebra.Setoid
  extend Algebra.Semigroup

  defmacro __using__(_) do
    quote do
      require Algebra.Monoid
      import  Algebra.Monoid

      use_dependencies
    end
  end

  where do
    @doc "Return the 'identity' or 'empty' element of the monoid"
    @operator ^
    identity(any) :: any
  end

  defproperty left_identity(monoid_a) do
    monoid == monoid_a <|> identity(monoid_a)
  end

  defproperty right_identity(monoid_a) do
    monoid == identity(monoid_a) <|> monoid_a
  end

  @operator ^^^
  def append_id(a), do: identity(a) <|> a
end

definstance Algebra.Monoid, for: List do
  def identity(_list), do: []
end
```

## Haskell

The rough equivalent in Haskell

```haskell
module Algebra.Monoid where

class (Setoid a, Semigroup a) => Monoid a where
  identity :: a -> a

  -- Not actually needed in this case
  -- Just here to illustrate including functions for minimal definitions
  append_id :: a -> a
  append_id a = identity a `append` a

instance Monoid [a] where
  identity _ = []
```
