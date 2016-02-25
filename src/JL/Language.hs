{-# LANGUAGE LambdaCase #-}
module JL.Language (expr) where

import Text.Megaparsec
import Text.Megaparsec.String
import Data.Char (isAlpha)
import qualified Data.Text as T
import qualified Text.Megaparsec.Lexer as L
import Control.Monad
import JL.Types
import Data.Aeson
import qualified Data.ByteString.Lazy.Char8 as C8 

-- parsing will look like
-- lhs-op-rhs
-- For get, op and rhs will be empty
-- For set, op: =, rhs is valid json
-- For modify, op: =>(:op)
ident :: Parser T.Text 
ident = T.pack <$> some (oneOf $ ['a'..'z'] ++ ['A'..'Z'])

key :: Parser Key
key = Key <$> (char '.' *> ident)

keys :: Parser [Key]
keys = some key

-- If invalid json, this should fail to parse, really...
value :: Parser Value
value = decode . C8.pack <$> some anyChar >>= \case
  Nothing -> mzero -- Note: This will fail to parse 
  Just val -> return val

expr :: Parser Expr
expr = try (Set <$> keys <*> (char '=' *> value)) <|> (Get <$> keys <* eof)

