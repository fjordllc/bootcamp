[![Test](https://github.com/fjordllc/bootcamp/actions/workflows/test.yml/badge.svg)](https://github.com/fjordllc/bootcamp/actions/workflows/test.yml)
[![Lint](https://github.com/fjordllc/bootcamp/actions/workflows/lint.yml/badge.svg)](https://github.com/fjordllc/bootcamp/actions/workflows/lint.yml)
[![Create a release pull-request](https://github.com/fjordllc/bootcamp/actions/workflows/git-pr-release-action.yml/badge.svg)](https://github.com/fjordllc/bootcamp/actions/workflows/git-pr-release-action.yml)

# Bootcamp

プログラマー向けEラーニングシステム。

## インストール

```
$ bin/setup
$ rails server
```

## practiceの所要時間の集計

学習時間記入した日報を投稿した上で、

```
$ rake bootcamp:statistics:save_learning_minute_statistics
```

## テスト

ヘッドレスブラウザーでテスト

```
$ rails test:all
```

普通のブラウザーでテスト

```
$ HEADED=1 rails test:all
```

## Lint

次のコマンドでlintを実行します。

```
$ ./bin/lint
```

実行されるlint

* Ruby
  * rubocop
  * slim-lint
* JavaScript
  * eslint
  * prettier
* eslintの警告は以下のコマンドで修正されますが、修正されない場合は手動で修正してください。

```shell
$ eslint 'app/javascript/**/*.{js,vue}' --fix
```

* prettierの警告が出ている場合には、以下のコマンドで修正できます。

```shell
$ prettier app/javascript/**/*.{js,vue} --write
```

## Profiler

rack-mini-profilerによりプロファイリングはデフォルトではOFFになっています。ONにする場合は下記のようにサーバーと立ち上げます。

```
$ PROFILE=1 rails server
```

## その他

- [Develop環境でログインする方法](https://github.com/fjordllc/bootcamp/wiki/Develop%E7%92%B0%E5%A2%83%E3%81%A7%E3%83%AD%E3%82%B0%E3%82%A4%E3%83%B3%E3%81%99%E3%82%8B%E6%96%B9%E6%B3%95)
- [Develop環境でのメールの確認方法](https://github.com/fjordllc/bootcamp/wiki/Develop%E7%92%B0%E5%A2%83%E3%81%A7%E3%81%AE%E3%83%A1%E3%83%BC%E3%83%AB%E3%81%AE%E7%A2%BA%E8%AA%8D%E6%96%B9%E6%B3%95)
- [nodeのバージョン切り替え](https://github.com/fjordllc/bootcamp/wiki/node%E3%81%AE%E3%83%90%E3%83%BC%E3%82%B8%E3%83%A7%E3%83%B3%E5%88%87%E3%82%8A%E6%9B%BF%E3%81%88)
- [Rake Taskの実装方法](https://github.com/fjordllc/bootcamp/wiki/Rake-Task%E3%81%AE%E5%AE%9F%E8%A3%85%E6%96%B9%E6%B3%95)
- [Develop環境をDockerで動かす方法](doc/development_on_docker.md)
- [通知機能](https://github.com/fjordllc/bootcamp/wiki/%E9%80%9A%E7%9F%A5%E6%A9%9F%E8%83%BD)
