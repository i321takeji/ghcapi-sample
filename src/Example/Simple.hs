-- 参考: https://wiki.haskell.org/GHC/As_a_library
module Example.Simple where

import GHC
import GHC.Paths ( libdir )
import DynFlags

main = defaultErrorHandler defaultFatalMessager defaultFlushOut $ do
            runGhc (Just libdir) $ do
            dflags <- getSessionDynFlags
            setSessionDynFlags dflags
            target <- guessTarget "test_main.hs" Nothing
            setTargets [target]
            load LoadAllTargets
