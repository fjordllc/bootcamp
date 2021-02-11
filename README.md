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

- [Develop環境でログインする方法](https://github.com/fjordllc/bootcamp/wiki/Develop%E7%92%B0%E5%A2%83%E3%81%A7%E3%83%AD%E3%82%B0%E3%82%A4%E3%83%B3%E3%81%99%E3%82%8B%E6%96%B9%E6%B3%95)

- [nodeのバージョン切り替え](https://github.com/fjordllc/bootcamp/wiki/node%E3%81%AE%E3%83%90%E3%83%BC%E3%82%B8%E3%83%A7%E3%83%B3%E5%88%87%E3%82%8A%E6%9B%BF%E3%81%88)

- [Rake Taskの実装方法](https://github.com/fjordllc/bootcamp/wiki/Rake-Task%E3%81%AE%E5%AE%9F%E8%A3%85%E6%96%B9%E6%B3%95)
