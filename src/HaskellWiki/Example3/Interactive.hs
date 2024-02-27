-- 参考: https://wiki.haskell.org/GHC/As_a_library
-- ＃ Running interactive statements」

import Control.Arrow ((&&&))
import Control.Exception.Base (SomeException (..))
import Data.List (find)
import Debugger (showTerm)
import DynFlags
  ( DynFlags (ghcLink, ghcMode, hscTarget),
    GhcLink (LinkInMemory),
    GhcMode (CompManager),
    HscTarget (HscInterpreted),
  )
import Exception (gtry)
import GHC
  ( ExecResult (execResult),
    GhcMonad,
    InteractiveImport (IIModule),
    LoadHowMuch (LoadAllTargets),
    ModSummary (ms_mod),
    Module (moduleName),
    TyThing (AnId),
    execOptions,
    execStmt,
    getModuleGraph,
    getSessionDynFlags,
    guessTarget,
    load,
    lookupName,
    mgModSummaries,
    obtainTermFromId,
    runGhc,
    setContext,
    setSessionDynFlags,
    setTargets,
  )
import GHC.Paths (libdir)
import GhcMonad (liftIO)
import HscTypes (msHsFilePath)
import Outputable
  ( defaultUserStyle,
    qualName,
    queryQual,
    showSDocForUser,
    text,
    (<+>),
  )
import Panic (panic)

targetFile :: String
targetFile = "src/HaskellWiki/Example3/sample.hs"

main :: IO ()
main = do
  runGhc (Just libdir) $ do
    dflags <- getSessionDynFlags
    setSessionDynFlags dflags {hscTarget = HscInterpreted, ghcLink = LinkInMemory, ghcMode = CompManager}
    target <- guessTarget targetFile Nothing
    setTargets [target]
    load LoadAllTargets
    modGraph <- getModuleGraph
    case find ((== targetFile) . msHsFilePath) (mgModSummaries modGraph) of
      Just modSum -> run modSum "mul (add 2 3) 4"
      Nothing -> panic "PANIC!!"

run :: (GhcMonad m) => ModSummary -> String -> m ()
run modSum expr = do
  setContext [IIModule $ moduleName $ ms_mod modSum]
  result <- execStmt expr execOptions
  case execResult result of
    Right ns ->
      do
        let q = (qualName &&& queryQual) . defaultUserStyle
        mapM_
          ( \n -> do
              mty <- lookupName n
              case mty of
                Just (AnId aid) -> do
                  df <- getSessionDynFlags
                  t <- gtry $ obtainTermFromId maxBound True aid
                  evalDoc <- case t of
                    Right term -> showTerm term
                    Left exn ->
                      return
                        ( text "*** Exception:"
                            <+> text (show (exn :: SomeException))
                        )
                  liftIO $ putStrLn $ showSDocForUser df (snd $ q df) evalDoc
                  return ()
                _ -> return ()
          )
          ns
    Left (SomeException e) -> liftIO $ print e
