-- 参考: https://wiki.haskell.org/GHC/As_a_library
module HaskellWiki.Example1.Simple where

import GHC
import GHC.Paths ( libdir )
import DynFlags

targetFile = "src/HaskellWiki/Example1/test_main.hs"

main = defaultErrorHandler defaultFatalMessager defaultFlushOut $ do
            runGhc (Just libdir) $ do
                dflags <- getSessionDynFlags
                setSessionDynFlags dflags
                target <- guessTarget targetFile Nothing
                setTargets [target]
                load LoadAllTargets
