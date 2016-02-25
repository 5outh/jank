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
import Control.Lens hiding (argument)

path :: (AsValue t) => [Key] -> Traversal' t Value
path [] = _Value 
path (i:is) = foldl' (.) (key (getKey i)) (map (key . getKey) is)

traversal :: AsValue t => Expr -> Traversal' t Value 
traversal (Get keys) = path keys
traversal (Set keys _) = path keys

interpret :: AsValue s => Expr -> s -> Maybe Value
interpret (Get keys) json 
  = json ^? path keys 
interpret (Set keys val) json
   = (path keys .~ val $ json) ^? _Value

-- TODO: Divorce parsing from evaluating
runJL :: String -> String -> Either ParseError (Maybe Value)
runJL json e
  = case parsed of
      Right expr -> return (interpret expr json)
      Left err -> Left err
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

