import Control.Monad.IO.Class (liftIO)
import CorePrep (corePrepPgm)
import CoreSyn (CoreProgram)
import CoreToStg (coreToStg)
import CostCentre (CollectedCCs, CostCentre)
import Data.List (find)
import Data.Set (Set)
import GHC
  ( GhcMonad (getSession),
    LoadHowMuch (LoadAllTargets),
    ModSummary (ms_location, ms_mod),
    coreModule,
    desugarModule,
    getModuleGraph,
    getSessionDynFlags,
    guessTarget,
    load,
    mgModSummaries,
    parseModule,
    runGhc,
    setSessionDynFlags,
    setTargets,
    typecheckModule,
  )
import GHC.Paths (libdir)
import HscTypes (ModGuts (mg_binds, mg_tcs), msHsFilePath)
import Outputable (Outputable (ppr), showSDoc)
import Panic (panic)
import StgSyn (StgTopBinding)

targetFile :: String
targetFile = "data/example/target.hs"

main :: IO ()
main = printStg

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
  let cm = coreModule d
      mod = ms_mod modsum
      loc = ms_location modsum
      core = mg_binds cm
      tcs = mg_tcs cm
  liftIO $ corePrepPgm env mod loc core tcs

getStg :: IO ([StgTopBinding], CollectedCCs)
getStg = do
  dflags <- runGhc (Just libdir) getSessionDynFlags
  modSum <- getMS
  (coreProg, _) <- getCorePrep modSum
  return $ coreToStg dflags (ms_mod modSum) coreProg
