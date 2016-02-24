{-# LANGUAGE RankNTypes #-}
module JL where

import Data.List (foldl')
import Data.Aeson.Lens
import Data.Aeson.Types hiding (parse)
import Control.Lens (Traversal', (^?))
import qualified Data.Text as T
import JL.Types
import JL.Language
import Text.Megaparsec (parse)
import Text.Megaparsec.Error

dotPath :: AsValue t => T.Text -> Traversal' t Value
dotPath = path . T.splitOn "."

path :: (AsValue t) => [T.Text] -> Traversal' t Value
path [] = _Value 
path (i:is) = foldl' (.) (key i) (map key is)

traversal :: AsValue t => Expr -> Traversal' t Value 
traversal (Get keys) = path keys

runJL :: String -> String -> Either ParseError (Maybe Value)
runJL json e
  = (\e_ -> json ^? traversal e_) <$> parsed 
  where
    parsed = parse expr "(error)" e 
