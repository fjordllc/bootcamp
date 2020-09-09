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
$ ./bin/test
```

普通のブラウザーでテスト

```
$ HEADED=1 ./bin/test
```

## Lint

rubocopとslim-lintを実行します。

```
$ ./bin/lint
```

## その他

- [nodeのバージョン切り替え](https://github.com/fjordllc/bootcamp/wiki/node%E3%81%AE%E3%83%90%E3%83%BC%E3%82%B8%E3%83%A7%E3%83%B3%E5%88%87%E3%82%8A%E6%9B%BF%E3%81%88)
