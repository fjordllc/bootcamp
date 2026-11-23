# CIのテスト所要時間の記録とシャードの振り分け

CI（`.github/workflows/ci.yml`）は、テストを複数のシャードに分けて並行に実行します。全体の時間は最も遅いシャードで決まるため、各シャードの合計時間が揃うように、記録した所要時間を使ってテストファイルを振り分けます。

## 流れ

1. `test` の各シャードは、`TEST_TIMINGS_PATH` を指定してテストを実行します。`test/supports/test_timings_reporter.rb` が、テストごとの所要時間と再試行の回数をJSONに書き出します。
2. `test-timings` ジョブが `bin/ci-test-timings merge` で各シャードの記録をまとめます。結果は run の Summary に表示し、`test-timings` という成果物として保存します。
3. main への push で全シャードが成功したときだけ、まとめた記録をキャッシュ（`test-timings-<run id>`）に保存します。
4. 次回以降の run では、`build` ジョブが最新の記録を復元し、`bin/ci-test-timings split` でテストファイルを振り分けます。各シャードは、その結果（成果物 `test-shards`）に従ってテストを実行します。

振り分けは `build` ジョブで一度だけ行います。シャードごとに計算すると、参照する記録がシャード間で食い違ったときに、どのシャードにも入らないテストが生じるためです。

## 振り分けの方法

- 所要時間の長いファイルから順に、その時点で合計が最も短いシャードへ入れます。
- 記録のないファイル（新しく追加したテストなど）は、記録のあるファイルの中央値として扱います。
- 記録が1つもないとき（キャッシュが消えたときなど）は、ファイル数が揃うように振り分けます。
- 振り分けに使うのは最後の実行の時間だけです。再試行に使った時間は含めません。

## Summaryの見方

run の Summary には、次の表が出ます。

- シャードごとのテスト数、合計時間、再試行に使った時間
- 遅いファイルと遅いテストの上位20件
- 再試行したテストと、その回数

時間はテスト本体（`setup` と `teardown` を含む）のもので、Railsの起動やファイルの読み込みは含みません。

## 手元で記録する

```bash
TEST_TIMINGS_PATH=tmp/test_timings/shard-0.json rails test test/models
bin/ci-test-timings merge --input tmp/test_timings --output tmp/test_timings.json
```

`PARALLEL_WORKERS` を2以上にした場合、再試行の回数と時間は記録されません。

## シャード数を変える

`.github/workflows/ci.yml` の `TEST_SHARDS` と、`test` ジョブの `matrix.shard` の両方を変えてください。
