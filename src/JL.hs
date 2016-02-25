{-# LANGUAGE RankNTypes #-}
module JL where

import Data.Aeson.Encode
import Data.Aeson.Lens
import Data.Aeson.Types hiding (parse, Parser)
import JL.Types
import JL.Language
import Text.Megaparsec (parse)
import Text.Megaparsec.Error
import Options.Applicative hiding (ParseError)
import qualified Data.ByteString.Lazy.Char8 as C8
import Control.Lens hiding (argument, Empty)

-- This could be refactored to use fold(l)
path :: AsValue t => PrimOp -> Traversal' t Value
path Empty = _Value
path (KeyAt k) = key (getKey k)
path (IndexAt i) = nth (getIndex i)
path (KeyAt k :+: o) = key (getKey k) . path o
path (IndexAt i :+: o) = nth (getIndex i) . path o
path (Empty :+: o) = path o
path (opA@(_ :+: _) :+: opB) = path opA . path opB

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
      Right e_ -> return (interpret e_ json)
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
    Right (Just val) -> C8.putStrLn (encode val)
    _ -> putStrLn "Something went wrong..."
  where 
    opts = info (helper <*> jl)
      ( fullDesc
       <> progDesc "Process JSON on the command line."
       <> header "JL - A CLI JSON Processor")

