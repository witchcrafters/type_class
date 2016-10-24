module Algebra.Monoid where

class (Setoid a, Semigroup a) => Monoid a where
  identity :: a -> a

  -- minimally complete definition
  append_id :: a -> a
  append_id a = identity a `append` a
  -- not actually needed in this case
  -- just here for illustration



instance Monoid [a] where
  identity _ = []
