module HaskellWiki.Example3.Interactive where

import GHC
import GhcMonad
import InteractiveEval hiding (obtainTermFromId)
import Outputable
import Exception (gtry)
import Debugger (showTerm)
-- import GHC.Paths ( libdir )

import Control.Exception.Base (SomeException (..))
import Control.Arrow ((&&&))

run :: (GhcMonad m) => ModSummary -> String -> m ()
run modSum expr = do
  setContext [IIModule $ moduleName $ ms_mod modSum]       
  result <- execStmt expr execOptions
  case execResult result of
    Right ns ->
      do
        let q = queryQual . defaultUserStyle
        mapM_ (\n -> do
                mty <- lookupName n
                case mty of
                  Just (AnId aid) -> do
                      df <- getSessionDynFlags
                      t <- gtry $ obtainTermFromId maxBound True aid
                      evalDoc <- case t of
                          Right term -> showTerm term
                          Left  exn  -> return (text "*** Exception:" <+>
                                                text (show (exn :: SomeException)))
                      liftIO $ putStrLn $ showSDocForUser df (q df) evalDoc
                      return ()
                  _ -> return ()
                ) ns
    Left (SomeException e) -> liftIO $ print e
