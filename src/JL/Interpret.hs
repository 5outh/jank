{-# LANGUAGE RankNTypes #-}
module JL.Interpret where

import JL.Types
import Data.Aeson.Encode
import Data.Aeson.Types hiding (parse, Parser)
import Data.Aeson.Lens
import Control.Lens hiding (argument, Empty, op)

-- This could be refactored to use fold(l) if PrimOp was Foldable
path :: AsValue t => PrimOp -> Traversal' t Value
path Empty = _Value
path (KeyAt k) = key (getKey k)
path (IndexAt i) = nth (getIndex i)
path (KeyAt k :+: o) = key (getKey k) . path o
path (IndexAt i :+: o) = nth (getIndex i) . path o
path (Empty :+: o) = path o
path (opA@(_ :+: _) :+: opB) = path opA . path opB

traversal :: AsValue t => Expr -> Traversal' t Value 
traversal (Get op) = path op
traversal (Set op _) = path op

interpret :: AsValue s => Expr -> s -> Maybe Value
interpret (Get op) json 
  = json ^? path op 
interpret (Set op val) json
   = (path op .~ val $ json) ^? _Value

