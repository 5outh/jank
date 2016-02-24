module Paths_jl (
    version,
    getBinDir, getLibDir, getDataDir, getLibexecDir,
    getDataFileName, getSysconfDir
  ) where

import qualified Control.Exception as Exception
import Data.Version (Version(..))
import System.Environment (getEnv)
import Prelude

catchIO :: IO a -> (Exception.IOException -> IO a) -> IO a
catchIO = Exception.catch

version :: Version
version = Version [0,0,1] []
bindir, libdir, datadir, libexecdir, sysconfdir :: FilePath

bindir     = "/Users/Ben/projects/jl/.stack-work/install/x86_64-osx/lts-5.2/7.10.3/bin"
libdir     = "/Users/Ben/projects/jl/.stack-work/install/x86_64-osx/lts-5.2/7.10.3/lib/x86_64-osx-ghc-7.10.3/jl-0.0.1-7Zlr6eHSU6qKrrI9puTOIz"
datadir    = "/Users/Ben/projects/jl/.stack-work/install/x86_64-osx/lts-5.2/7.10.3/share/x86_64-osx-ghc-7.10.3/jl-0.0.1"
libexecdir = "/Users/Ben/projects/jl/.stack-work/install/x86_64-osx/lts-5.2/7.10.3/libexec"
sysconfdir = "/Users/Ben/projects/jl/.stack-work/install/x86_64-osx/lts-5.2/7.10.3/etc"

getBinDir, getLibDir, getDataDir, getLibexecDir, getSysconfDir :: IO FilePath
getBinDir = catchIO (getEnv "jl_bindir") (\_ -> return bindir)
getLibDir = catchIO (getEnv "jl_libdir") (\_ -> return libdir)
getDataDir = catchIO (getEnv "jl_datadir") (\_ -> return datadir)
getLibexecDir = catchIO (getEnv "jl_libexecdir") (\_ -> return libexecdir)
getSysconfDir = catchIO (getEnv "jl_sysconfdir") (\_ -> return sysconfdir)

getDataFileName :: FilePath -> IO FilePath
getDataFileName name = do
  dir <- getDataDir
  return (dir ++ "/" ++ name)
