module Paths_SnapChat (
    version,
    getBinDir, getLibDir, getDataDir, getLibexecDir,
    getDataFileName
  ) where

import Data.Version (Version(..))
import System.Environment (getEnv)

version :: Version
version = Version {versionBranch = [0,1,0], versionTags = []}

bindir, libdir, datadir, libexecdir :: FilePath

bindir     = "/Users/tjweir/Library/Haskell/ghc-7.0.3/lib/SnapChat-0.1.0/bin"
libdir     = "/Users/tjweir/Library/Haskell/ghc-7.0.3/lib/SnapChat-0.1.0/lib"
datadir    = "/Users/tjweir/Library/Haskell/ghc-7.0.3/lib/SnapChat-0.1.0/share"
libexecdir = "/Users/tjweir/Library/Haskell/ghc-7.0.3/lib/SnapChat-0.1.0/libexec"

getBinDir, getLibDir, getDataDir, getLibexecDir :: IO FilePath
getBinDir = catch (getEnv "SnapChat_bindir") (\_ -> return bindir)
getLibDir = catch (getEnv "SnapChat_libdir") (\_ -> return libdir)
getDataDir = catch (getEnv "SnapChat_datadir") (\_ -> return datadir)
getLibexecDir = catch (getEnv "SnapChat_libexecdir") (\_ -> return libexecdir)

getDataFileName :: FilePath -> IO FilePath
getDataFileName name = do
  dir <- getDataDir
  return (dir ++ "/" ++ name)
