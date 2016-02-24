module JL.Types (
  Expr(..)
) where

import qualified Data.Text as T

data Expr
  = Get [T.Text] -- For now, this is hardcoded to a list of keys, eventually it may be a Lens
    deriving (Show, Eq)
