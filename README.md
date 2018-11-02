# Bootcamp

プログラマー向けEラーニングシステム。

## インストール
```bash
$ brew install yarn
$ bin/setup
$ yarn install
$ rails s
```

You can also launch a web server with [rack-mini-profiler](https://github.com/MiniProfiler/rack-mini-profiler).

```bash
$ RACK_PROFILER=1 rails s
```

### インストール時エラー関係

#### 以下のエラーが出た場合
```
An error occurred while installing pg (1.1.3), and Bundler cannot continue.
Make sure that `gem install pg -v '1.1.3' --source 'https://rubygems.org/'` succeeds before bundling.
```

`PostgreSQL` がインストールされていない可能性がある。  
```bash
# インストール
$ brew install postgresql
# 起動
$ brew services start postgresql
```

#### `yarn install` で引っかかる場合
`node.js` が入っていない可能性がある。  
`brew install node` を叩いて再実行する。

----

## テスト

Test with headless browser.

```bash
$ ./bin/test
```

Test with real browser.

```bash
$ HEADED=1 ./bin/test
```

----

## Lint

`rubocop` と `slim-lint` を実行します。

```bash
$ ./bin/lint
```

----

## ER図
お使いの環境がMacである場合、以下のコマンドでER図を生成することができます。  
オプション指定でいろいろできるみたいなので、詳しくは [こちら](https://github.com/voormedia/rails-erd) をご覧ください。

**`console`**
```bash
# Gemを取ってくる
$ bundle install

# 先にローカル環境でGraphvizをインストールする
$ brew install graphviz

# ER図生成（生成後はプロジェクト直下にerd.pdfファイルが生成される）
$ bundle exec erd
```
