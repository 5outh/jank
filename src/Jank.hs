module Jank where

import Data.Aeson.Types hiding (parse, Parser)
import Data.Aeson.Encode (encode)
import Jank.Language
import Text.Megaparsec (parse)
import Text.Megaparsec.Error
import Options.Applicative hiding (ParseError)
import qualified Data.ByteString.Lazy.Char8 as C8
import Jank.Interpret

printValue :: Value -> IO ()
printValue (Array arr) = mapM_ printValue arr
printValue val = C8.putStrLn (encode val)

-- TODO: Divorce parsing from evaluating
runJank :: String -> String -> Either ParseError (Maybe Value)
runJank json e
  = case parsed of
      Right e_ -> return (interpret e_ json)
      Left err -> Left err
  where
    parsed = parse expr "(error)" e 

jank :: Parser (String, String)
jank = (,)
  <$> argument str (metavar "JSON")
  <*> argument str (metavar "COMMAND")

go :: String -> String -> IO ()
go json cmd = case runJank json cmd of
  Right (Just val) -> printValue val
  Right Nothing -> putStrLn "null"
  Left err -> print err

start :: IO ()
start = execParser opts >>= uncurry go
  where 
    opts = info (helper <*> jank)
      ( fullDesc
       <> progDesc "Process JSON on the command line."
       <> header "Jank - A CLI JSON Processor")

