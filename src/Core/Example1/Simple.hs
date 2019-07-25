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
  cm <- getCoreModule
  let pshow x = showSDoc dflags $ ppr x
  putStrLn $ unlines [ "==== cm_module :: !Module ===="
                     , pshow $ cm_module cm
                     , ""
                     , "==== cm_types :: !HscTypes.TypeEnv ===="
                     , pshow $ cm_types cm
                     , ""
                     , "==== cm_binds :: CoreProgram ===="
                     , pshow $ cm_binds cm
                     , ""
                     , "==== cm_safe :: SafeHaskellMode ===="
                     , pshow $ cm_safe cm
                     ]

getCoreModule :: IO CoreModule
getCoreModule = runGhc (Just libdir) $ do
  getSessionDynFlags >>= setSessionDynFlags
  compileToCoreModule targetFile
