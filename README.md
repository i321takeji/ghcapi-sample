# ghcapi-sample

GHC API の使い方をお勉強．

## 参考ページ

- HaskellWiki -- GHC/As a library, https://wiki.haskell.org/GHC/As_a_library
- GHC API で型を表示 -- eagletmtの日記, https://haskell.g.hatena.ne.jp/eagletmt/20091012/1255349481
- GHC API を使ってある型コンストラクタのデータコンストラクタを得る -- EAGLE 雑記, https://eagletmt.hatenadiary.org/entry/20111129/1322589884

## サンプルと実行例

- HaskellWiki に載っていたサンプル
    - [その1](/src/HaskellWiki/Example1/)：`ghc --make` と同じことを行うプログラム
        ```sh
        $ stack run haskellwiki-ex1
        ```
        ```sh
        $ ./src/HaskellWiki/Example1/test_main
        Hello GHC API!
        ```
    - [その2](/src/HaskellWiki/Example2/)：`parseModule`, `typecheckModule`, `desugarModule`, `getNamesInScope`, `getModuleGraph` を呼び出すプログラム
    ```sh
    $ stack repl src/HaskellWiki/Example2/A.hs 
    ```
    ```
    *HaskellWiki.Example2.A> main
    (module HaskellWiki.Example2.B where
    main = print "Hello, World!",
    [/, n, -, -, -, -, -, /, n],
    {$trModule
        = Module (TrNameS "main"#) (TrNameS "HaskellWiki.Example2.B"#),
    main = print "Hello, World!"})
    ```
    - [その3](/src/HaskellWiki/Example3/)
- [Core を出力するだけ](/src/Core/Example1/) (対象ファイル [/src/Core/Example1/sample.hs](/src/Core/Example1/sample.hs))
    ```sh
    $ stack repl src/Core/Example1/Simple.hs
    ```
    ```
    *Core.Example1.Simple> printCoreModule
    ==== cm_module :: !Module ====
    Foo

    ==== cm_types :: !HscTypes.TypeEnv ====
    [rn5W :-> Identifier ‘f’, rn5X :-> Identifier ‘main’,
    rn5Y :-> Identifier ‘$trModule’]

    ==== cm_binds :: CoreProgram ====
    [f :: forall p. p -> p
    [LclIdX]
    f = \ (@ p) (x :: p) -> x,
    $trModule :: Module
    [LclIdX]
    $trModule = Module (TrNameS "main"#) (TrNameS "Foo"#),
    main :: IO ()
    [LclIdX]
    main
    = $ @ 'LiftedRep
        @ Integer
        @ (IO ())
        (print @ Integer $fShowInteger)
        (f @ Integer 10)]

    ==== cm_safe :: SafeHaskellMode ====
    Safe
    ```
- [STG を出力するだけ](/src/Stg/Example1/) (対象ファイル, [/src/Stg/Example1/sample.hs](/src/Stg/Example1/sample.hs))
    ```bash
    $ stack repl src/Core/Example1/Simple.hs
    ```
    ```
    *Stg.Example1.Simple> printStg
    [sat_soEf :: forall p. p -> p
    [LclId] =
        [] \r [x] x;,
    f :: forall p. p -> p
    [LclIdX] =
        [] \u [] sat_soEf;,
    sat_soEi :: TrName
    [LclId] =
        CCS_DONT_CARE TrNameS! ["Foo"#];,
    sat_soEh :: TrName
    [LclId] =
        CCS_DONT_CARE TrNameS! ["main"#];,
    $trModule :: Module
    [LclIdX] =
        CCS_DONT_CARE Module! [sat_soEh sat_soEi];,
    sat_soEx :: Integer
    [LclId] =
        [] \u []
            let {
            sat_soEw [Occ=Once] :: Integer
            [LclId] =
                CCCS S#! [10#];
            } in  f sat_soEw;,
    sat_soEk :: Integer -> IO ()
    [LclId] =
        [] \u [] print $fShowInteger;,
    main :: IO ()
    [LclIdX] =
        [] \u [] $ sat_soEk sat_soEx;]
    ```
