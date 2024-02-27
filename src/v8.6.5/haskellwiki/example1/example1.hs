-- 参考: https://wiki.haskell.org/GHC/As_a_library
-- # A Simple Example

import DynFlags (defaultFatalMessager, defaultFlushOut)
import GHC
  ( LoadHowMuch (LoadAllTargets),
    SuccessFlag,
    defaultErrorHandler,
    getSessionDynFlags,
    guessTarget,
    load,
    runGhc,
    setSessionDynFlags,
    setTargets,
  )
import GHC.Paths (libdir)

targetFile :: String
targetFile = "data/haskellwiki/example1/test_main.hs"

main :: IO SuccessFlag
main = defaultErrorHandler defaultFatalMessager defaultFlushOut $ do
  runGhc (Just libdir) $ do
    dflags <- getSessionDynFlags
    setSessionDynFlags dflags
    target <- guessTarget targetFile Nothing
    setTargets [target]
    load LoadAllTargets
