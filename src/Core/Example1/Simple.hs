module Core.Example1.Simple where

import GHC
import GHC.Paths ( libdir )
import DynFlags
import CoreSyn
import Outputable

targetFile = "sample.hs"

printCoreModule = do
  (dflags, core) <- testCoreModule
  putStrLn $ showSDoc dflags $ ppr core

testCoreModule = runGhc (Just libdir) $ do
  dflags <- getSessionDynFlags
  setSessionDynFlags dflags
  cm <- compileToCoreModule targetFile
  return $ (dflags, cm_binds cm)
--  return $ showSDoc dflags $ ppr $ cm_binds cm
