{-# LANGUAGE RankNTypes #-}
module JL where

import Data.List (foldl')
import Data.Aeson hiding (json)
import Data.Aeson.Lens
import Data.Aeson.Types
import Control.Lens (Traversal')
import qualified Data.Text as T

dotPath :: AsValue t => T.Text -> Traversal' t Value
dotPath = path . T.splitOn "."

path :: (AsValue t) => [T.Text] -> Traversal' t Value
path [] = _Value 
path (i:is) = foldl' (.) (key i) (map key is)

