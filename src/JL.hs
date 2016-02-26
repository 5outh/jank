module JL where

import Data.Aeson.Types hiding (parse, Parser)
import Data.Aeson.Encode (encode)
import JL.Language
import Text.Megaparsec (parse)
import Text.Megaparsec.Error
import Options.Applicative hiding (ParseError)
import qualified Data.ByteString.Lazy.Char8 as C8
import JL.Interpret

printValue :: Value -> IO ()
printValue (Array arr) = mapM_ printValue arr
printValue val = C8.putStrLn (encode val)

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
    Right (Just val) -> printValue val
    Right Nothing ->putStrLn "null" 
    Left err -> print err 
  where 
    opts = info (helper <*> jl)
      ( fullDesc
       <> progDesc "Process JSON on the command line."
       <> header "JL - A CLI JSON Processor")

