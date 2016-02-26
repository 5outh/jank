{-# LANGUAGE RankNTypes #-}
module Jank.Interpret where

import Jank.Types
import Data.Aeson.Types hiding (parse, Parser)
import Data.Aeson.Lens
import Control.Lens hiding (argument, Empty, op)
import qualified Data.Vector as Vector

-- This could be refactored to use fold(l) if PrimOp was Foldable
path :: AsValue t => PrimOp -> Traversal' t Value
path Empty = _Value
path (KeyAt k) = key (getKey k)
path (IndexAt i) = nth (getIndex i)
path AllElements = values
path (opA :+: opB) = path opA . path opB

interpret :: AsValue s => Expr -> s -> Maybe Value
interpret (Get op) json 
  = json ^? path op 
interpret (Set op val) json
   = (path op .~ val $ json) ^? _Value
-- TODO: Clean up?
interpret (GetIndexed op) json
  = Just $ Array $ Vector.fromList (json ^.. path op)
interpret (SetIndexed op val) json
  = (path op .~ val $ json) ^? _Value

