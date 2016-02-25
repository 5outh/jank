module JL.Types (
  Expr(..),
  Key(..)
) where

import qualified Data.Text as T
import Data.Aeson (Value)

newtype Key = Key{ getKey :: T.Text }
  deriving (Show, Eq)

-- Eventually we may just use a lens, then get/set etc becomes
-- very simple
data Expr
  = Get [Key] -- get @ path in object 
  | Set [Key] Value -- set path in object to value
    deriving (Show, Eq)

