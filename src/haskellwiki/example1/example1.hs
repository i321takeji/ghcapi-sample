-- 参考: https://wiki.haskell.org/GHC/As_a_library
-- # A Simple Example

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
import GHC.Driver.DynFlags
  ( defaultFatalMessager,
    defaultFlushOut,
  )
import GHC.Paths (libdir)

targetFile :: String
targetFile = "src/haskellwiki/example1/test_main.hs"

main :: IO SuccessFlag
main = defaultErrorHandler defaultFatalMessager defaultFlushOut $ do
  runGhc (Just libdir) $ do
    dflags <- getSessionDynFlags
    setSessionDynFlags dflags
    target <- guessTarget targetFile Nothing Nothing
    setTargets [target]
    load LoadAllTargets
