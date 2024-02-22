module Stg.Example1.Simple where

import GHC
import GHC.Paths              ( libdir )
import Outputable             ( ppr, showSDoc, panic )
import HscTypes
import CoreSyn                ( CoreProgram )
import CorePrep               ( corePrepPgm )
import CoreToStg              ( coreToStg )
import CostCentre             ( CostCentre, CollectedCCs )
import StgSyn                 ( StgTopBinding )

import Data.List              ( find )
import Data.Set               ( Set )
import Control.Monad.IO.Class ( liftIO )

targetFile = "src/Stg/Example1/sample.hs"

printStg :: IO ()
printStg = do
  dflags <- runGhc (Just libdir) getSessionDynFlags
  (stg, _) <- getStg
  putStrLn $ showSDoc dflags $ ppr stg

getMS :: IO ModSummary
getMS = runGhc (Just libdir) $ do
  getSessionDynFlags >>= setSessionDynFlags
  target <- guessTarget targetFile Nothing
  setTargets [target]
  load LoadAllTargets
  modGraph <- getModuleGraph
  case find ((== targetFile) . msHsFilePath) (mgModSummaries modGraph) of
    Just modSum -> return modSum
    Nothing -> panic "PANIC!!"

getCorePrep :: ModSummary -> IO (CoreProgram, Set CostCentre)
getCorePrep modsum = runGhc (Just libdir) $ do
  env <- getSession
  d <- parseModule modsum >>= typecheckModule >>= desugarModule
  let cm   = coreModule d
      mod  = ms_mod modsum
      loc  = ms_location modsum
      core = mg_binds cm
      tcs  = mg_tcs cm
  liftIO $ corePrepPgm env mod loc core tcs

getStg :: IO ([StgTopBinding], CollectedCCs) 
getStg = do
  dflags <- runGhc (Just libdir) getSessionDynFlags
  modSum <- getMS
  (coreProg, _) <- getCorePrep modSum
  return $ coreToStg dflags (ms_mod modSum) coreProg

