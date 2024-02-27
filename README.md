# ghcapi-sample

GHC API の使い方をお勉強．

## 参考ページ

- HaskellWiki -- GHC/As a library, https://wiki.haskell.org/GHC/As_a_library
- GHC API で型を表示 -- eagletmtの日記, https://haskell.g.hatena.ne.jp/eagletmt/20091012/1255349481
- GHC API を使ってある型コンストラクタのデータコンストラクタを得る -- EAGLE 雑記, https://eagletmt.hatenadiary.org/entry/20111129/1322589884

## サンプルのバージョン

- [GHC API 8.6.5](https://hackage.haskell.org/package/ghc-8.6.5)

## サンプルと実行例

- HaskellWiki に載っていたサンプル
    - [その1](/src/haskellwiki/example1/example1.hs)：`ghc --make` と同じことを行うプログラム
        ```sh
        $ stack run haskellwiki-ex1
        ```
        ```sh
        $ ./src/haskellwiki/example1/test_main
        Hello GHC API!
        ```
    - [その2](/src/haskellwiki/example2/)：`parseModule`, `typecheckModule`, `desugarModule`, `getNamesInScope`, `getModuleGraph` を呼び出すプログラム
        ```
        $ stack run haskellwiki-ex2
        module B where
        main = print "Hello, World!"

        -----

        {$trModule = Module (TrNameS "main"#) (TrNameS "B"#),
        main = print "Hello, World!"}
        ```
    - [その3](/src/haskellwiki/example3/example3.hs)：モジュール (`sample.hs`) をロードした後，GHCi のように対話的に文 (`mul (add 2 3) 4`) を実行
        ```sh
        $ stack run haskellwiki-ex3
        20
        20
        ```
- [Core を出力するだけ](/src/core/example1/example1.hs) (対象ファイル [/src/core/example1/sample.hs](/src/core/example1/sample.hs))
    ```
    $ stack run core-ex1
    ==== cm_module :: !Module ====
    Foo
    
    ==== cm_types :: !HscTypes.TypeEnv ====
    [r1 :-> Identifier ‘f’, r2 :-> Identifier ‘main’,
     r3 :-> Identifier ‘$trModule’]
    
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
- [STG を出力するだけ](/src/stg/example1/example1.hs) (対象ファイル, [/src/stg/example1/sample.hs](/src/stg/example1/sample.hs))
    ```
    $ stack run stg-ex1
    [sat_s2C2 :: forall p. p -> p
     [LclId] =
         [] \r [x] x;,
     f :: forall p. p -> p
     [LclIdX] =
         [] \u [] sat_s2C2;,
     sat_s2C5 :: TrName
     [LclId] =
         CCS_DONT_CARE TrNameS! ["Foo"#];,
     sat_s2C4 :: TrName
     [LclId] =
         CCS_DONT_CARE TrNameS! ["main"#];,
     $trModule :: Module
     [LclIdX] =
         CCS_DONT_CARE Module! [sat_s2C4 sat_s2C5];,
     sat_s2Ck :: Integer
     [LclId] =
         [] \u []
             let {
               sat_s2Cj [Occ=Once] :: Integer
               [LclId] =
                   CCCS S#! [10#];
             } in  f sat_s2Cj;,
     sat_s2C7 :: Integer -> IO ()
     [LclId] =
         [] \u [] print $fShowInteger;,
     main :: IO ()
     [LclIdX] =
         [] \u [] $ sat_s2C7 sat_s2Ck;]
    ```
