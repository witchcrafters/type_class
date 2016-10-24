module Algebra.Monoid where

class (Setoid a, Semigroup a) => Monoid a where
  identity :: a -> a

  -- minimally complete & aliases
  (^) :: a -> a
  (^) = identity

append_id :: a -> a
append_id a = identity a `append` a

instance Monoid [] where
  identity _ = []
