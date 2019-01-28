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

## node の version 切り替え

この方法は、

- nodebrew を使って node のバージョンの切り替えを行っている
- シェルに zsh を使っている

の場合にだけ使えます。

### .zshrc に追記

このプロジェクトのトップディレクトリに `.node-version` というファイルが含まれています。このファイルには、このプロジェクトで使う Node.js のバージョンが書かてています（[.node-version](https://github.com/fjordllc/bootcamp/blob/master/.node-version)）。

以下を `.zshrc` に追記すると、このアプリのディレクトリに入った際に、例えば `$ nodebrew user XXX` などのコマンドを打たなくても自動で `.node-version` が指定するバージョンの Node.js を使うようになります。

```bash
# カレントディレクトリの変更で自動的にNode.jsのバージョンを変える
function chpwd_node_version() {
  if [ -e ".node-version" ]; then
    version=`cat .node-version`
    nodebrew use $version
  fi
}
autoload -Uz add-zsh-hook
add-zsh-hook chpwd chpwd_node_version
```

### .zshrc に追記しない場合

以下のコマンドを打つと `.node-version` が指定するバージョンの Node.js を使うようになります。

```bash
nodebrew use $(cat .node-version)
```
