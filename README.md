# Bootcamp

プログラマー向けEラーニングシステム。

## インストール

    $ brew install yarn
    $ bin/setup
    $ yarn install
    $ rails s

You can also launch a web server with [rack-mini-profiler](https://github.com/MiniProfiler/rack-mini-profiler).

    $ RACK_PROFILER=1 rails s

## テスト

Test with headless browser.

```
$ ./bin/test
```

Test with real browser.

```
$ HEADED=1 ./bin/test
```

## Lint

rubocopとslim-lintを実行します。

```
$ ./bin/lint
```

## ER図
お使いの環境がMacである場合、以下のコマンドでER図を生成することができます。  
オプション指定でいろいろできるみたいなので、詳しくは https://github.com/voormedia/rails-erd をご覧ください。

**`console`**
```bash
# 先にローカル環境でGraphvizをインストールする
$ brew install graphviz

# ER図生成（生成後はプロジェクト直下にerd.pdfファイルが生成される）
$ bundle exec erd
```
