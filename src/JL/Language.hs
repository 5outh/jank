{-# LANGUAGE RecursiveDo #-}
module JL.Language (expr) where

import Text.Megaparsec
import Text.Megaparsec.String
import Data.Char (isAlpha)
import qualified Data.Text as T
import qualified Text.Megaparsec.Lexer as L
import Control.Monad
import JL.Types

ident :: Parser String 
ident = some (oneOf $ ['a'..'z'] ++ ['A'..'Z'])

key :: Parser String
key = char '.' >> ident

keys :: Parser [T.Text]
keys = map T.pack <$> some key

expr :: Parser Expr
expr = Get <$> keys

-- jl "{\"a\": 8}" ".a" -- 8


