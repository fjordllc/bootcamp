# Bootcamp

プログラマー向けEラーニングシステム。

## インストール

    $ brew install yarn
    $ bin/setup
    $ yarn install
    $ rails s

## テスト

Test with headless browser.

```
$ ./bin/test
```

Test with real browser.

```
$ HEADED=1 ./bin/test
```

---

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

## Xray-rails

 [Xray-rails](https://github.com/brentd/xray-rails) という Gem を使っています。Develop 環境で 3 つのキー `cmd` 、 `shift` 、 `x` を同時に押すと、

![3つのキー `cmd` 、 `shift` 、 `x` を同時に押すと](https://i.gyazo.com/da31297bfbfa3a921ee9e0cead991b62.png)

このように、赤い枠のブロックが表示されます。

その状態で、右下の歯車のアイコンをクリックすると、Editor のテキスト入力フィールドが表示されます。

![歯車のアイコンをクリック](https://i.gyazo.com/744609563aca458aa940aafa1f0d23a6.png)

このテキスト入力フィールドにエディタへのパス（VS Codeの場合は `/usr/local/bin/code`）を入力し、`Save` ボタンをクリック。

赤い枠のブロックが表示されている状態で 3 つのキー `cmd` 、 `shift` 、 `x` を同時に押すと、赤い枠のブロックは非表示になります。

もう一度、3 つのキー `cmd` 、 `shift` 、 `x` を同時に押し、赤い枠のブロックを表示させたら、自分が編集したいブロックをクリックします。すると、その部分の view ファイルが先ほどパスを保存したエディタで開きます。
