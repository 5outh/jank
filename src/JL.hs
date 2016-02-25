{-# LANGUAGE RankNTypes #-}
module JL where

import Data.List (foldl')
import Data.Aeson.Encode
import Data.Aeson.Lens
import Data.Aeson.Types hiding (parse, Parser)
import Control.Lens (Traversal', (^?))
import qualified Data.Text as T
import JL.Types
import JL.Language
import Text.Megaparsec (parse)
import Text.Megaparsec.Error
import Options.Applicative hiding (ParseError)
import Control.Monad
import qualified Data.ByteString.Lazy as BL

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

jl :: Parser (String, String)
jl = (,)
  <$> argument str (metavar "JSON")
  <*> argument str (metavar "COMMAND")

start :: IO ()
start = do
  (json, cmd) <- execParser opts
  case runJL json cmd of
    Right (Just val) -> BL.putStrLn (encode val) 
    _ -> putStrLn "Something went wrong..."
  where 
    opts = info (helper <*> jl)
      ( fullDesc
       <> progDesc "Process JSON on the command line."
       <> header "JL - A CLI JSON Processor")
