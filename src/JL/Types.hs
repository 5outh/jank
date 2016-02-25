module JL.Types where

import qualified Data.Text as T
import Data.Aeson (Value)

newtype Key = Key{ getKey :: T.Text }
  deriving (Show, Eq)

newtype Index = Index{ getIndex :: Int }
  deriving (Show, Eq)

data PrimOp
  = KeyAt Key
  | IndexAt Index
  | PrimOp :+: PrimOp
  | Empty 
    deriving (Show, Eq)

instance Monoid PrimOp where
  mappend = (:+:)
  mempty = Empty

-- Eventually we may just use a lens, then get/set etc becomes
-- very simple
data Expr
  = Get PrimOp -- get @ path in object 
  | Set PrimOp Value -- set path in object to value
    deriving (Show, Eq)

