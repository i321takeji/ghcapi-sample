-- 参考: https://wiki.haskell.org/GHC/As_a_library
{-# LANGUAGE CPP #-}
module Example.Simple where

import GHC
import GHC.Paths ( libdir )
import DynFlags

main =
#if __GLASGOW_HASKELL__ > 704
    defaultErrorHandler defaultFatalMessager defaultFlushOut $ do
#else
    defaultErrorHandler defaultLogAction $ do
#endif
      runGhc (Just libdir) $ do
        dflags <- getSessionDynFlags
        setSessionDynFlags dflags
        target <- guessTarget "test_main.hs" Nothing
        setTargets [target]
        load LoadAllTargets
