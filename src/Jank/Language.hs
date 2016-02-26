{-# LANGUAGE LambdaCase #-}
module Jank.Language (expr) where

import Text.Megaparsec
import Text.Megaparsec.String
import qualified Data.Text as T
import qualified Text.Megaparsec.Lexer as L
import Control.Monad
import Jank.Types
import Data.Aeson
import qualified Data.ByteString.Lazy.Char8 as C8 

-- parsing will look like
-- lhs-op-rhs
-- For get, op and rhs will be empty
-- For set, op: =, rhs is valid json
-- For modify, op: =>(:op)
ident :: Parser T.Text 
ident = T.pack <$> some (oneOf $ ['a'..'z'] ++ ['A'..'Z'])

keyAt :: Parser PrimOp
keyAt = KeyAt . Key <$> (char '.' *> ident)

integer :: Parser Int
integer = fromInteger <$> L.integer

indexAt :: Parser PrimOp
indexAt = IndexAt . Index <$> between (char '[') (char ']') integer

allElements :: Parser PrimOp
allElements = string "[]" *> pure AllElements

operation :: Parser PrimOp
operation 
  = mconcat <$> some (choice
      [ try allElements
      , try indexAt
      , keyAt
      ])

setExpr :: Parser Expr
setExpr = do
  (op_, val) <- (,) <$> operation <*> (char '=' *> value)
  pure (if isIndexed op_ then SetIndexed op_ val else Set op_ val)

getExpr :: Parser Expr
getExpr = do
  op_ <- operation <* eof
  pure (if isIndexed op_ then GetIndexed op_ else Get op_)

isIndexed :: PrimOp -> Bool
isIndexed AllElements = True
isIndexed (op :+: Empty) = isIndexed op
isIndexed (_ :+: op) = isIndexed op
isIndexed _ = False

-- If invalid json, this should fail to parse, really...
value :: Parser Value
value = decode . C8.pack <$> some anyChar >>= \case
  Nothing -> mzero -- Note: This will fail to parse 
  Just val -> return val

expr :: Parser Expr
expr = choice
  [ try setExpr
  , getExpr
  ]
