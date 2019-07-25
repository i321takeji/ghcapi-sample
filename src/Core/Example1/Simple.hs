module Core.Example1.Simple where

import GHC
import GHC.Paths ( libdir )
import DynFlags
import CoreSyn
import Outputable

targetFile = "sample.hs"

printCoreModule :: IO ()
printCoreModule = do
  dflags <- runGhc (Just libdir) getSessionDynFlags
  coreProg <- getCoreModule
  putStrLn "=== Core Program ==="
  putStrLn $ showSDoc dflags $ ppr coreProg

getCoreModule :: IO CoreProgram
getCoreModule = runGhc (Just libdir) $ do
  getSessionDynFlags >>= setSessionDynFlags
  cm <- compileToCoreModule targetFile
  return $ cm_binds cm
