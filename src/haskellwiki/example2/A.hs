-- 参考: https://wiki.haskell.org/GHC/As_a_library
-- # Another example

--A.hs
--invoke: ghci -package ghc A.hs
module A where

import DynFlags (defaultFatalMessager, defaultFlushOut, xopt_set)
import GHC
  ( GenLocated,
    GhcPs,
    HsModule,
    LoadHowMuch (LoadAllTargets),
    ParsedMod (parsedSource),
    ParsedSource,
    SrcSpan,
    TypecheckedMod (typecheckedSource),
    TypecheckedSource,
    coreModule,
    defaultErrorHandler,
    desugarModule,
    getModSummary,
    getModuleGraph,
    getNamesInScope,
    getSessionDynFlags,
    guessTarget,
    load,
    loadModule,
    mgModSummaries,
    mkModuleName,
    parseModule,
    runGhc,
    setSessionDynFlags,
    setTargets,
    showModule,
    typecheckModule,
  )
import GHC.LanguageExtensions.Type
  ( Extension (Cpp, ImplicitPrelude, MagicHash),
  )
import GHC.Paths (libdir)
--GHC.Paths is available via cabal install ghc-paths
import Outputable (Outputable (ppr), showSDoc, text, vcat)

targetFile :: String
targetFile = "src/haskellwiki/example2/B.hs"

main :: IO ()
main = do
  res <- example
  str <- runGhc (Just libdir) $ do
    dflags <- getSessionDynFlags
    let pprResult (ps, ts) = vcat [ppr ps, text "\n-----\n", ppr ts]
    return $ showSDoc dflags $ pprResult res
  putStrLn str

example :: IO (ParsedSource, TypecheckedSource)
example =
  defaultErrorHandler defaultFatalMessager defaultFlushOut $ do
    runGhc (Just libdir) $ do
      dflags <- getSessionDynFlags
      let dflags' =
            foldl
              xopt_set
              dflags
              [Cpp, ImplicitPrelude, MagicHash]
      setSessionDynFlags dflags'
      target <- guessTarget targetFile Nothing
      setTargets [target]
      load LoadAllTargets
      modSum <- getModSummary $ mkModuleName "B"
      p <- parseModule modSum
      t <- typecheckModule p
      d <- desugarModule t
      l <- loadModule d
      n <- getNamesInScope
      c <- return $ coreModule d

      g <- getModuleGraph
      mapM_ showModule $ mgModSummaries g
      return (parsedSource d, typecheckedSource d)
