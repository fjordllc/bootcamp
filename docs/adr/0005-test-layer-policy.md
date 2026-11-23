# 0005: ブラウザーを使うシステムテストを主要な流れに絞る

- 状態: 提案中
- 日付: 2026-11-22

## 背景

CIのテスト時間の93%をシステムテストが占めている。2026-11-22時点のmainの計測では、ブラウザーを使うシステムテストが1374件で合計2635秒、1件の平均は1.9秒だった。`BrowserlessSystemTestCase`（rack_test）を使うテストは281件で71秒、1件の平均は0.25秒である。モデル、結合、コントローラーなど残りの層は全部で約190秒である。

システムテストの中には、権限の確認、入力検証、並び順、通知の発生など、ブラウザーがなくても確かめられる内容が多い。同じ共通部品を対象ごとに繰り返すテストや、役割だけを変えて繰り返すテストもある。どの層に何を書くかの基準がなく、新しい機能のテストはシステムテストとして追加されやすい。

テストが遅いと、CIの待ち時間が伸びるだけでなく、手元やエージェントでの確認も遅くなる。

## 決定

テストは、その内容を確かめられる最も速い層に書く。ブラウザーを使うシステムテストは、次のどちらかに当てはまるものだけにする。

1. 主要な利用の流れが最初から最後まで成功すること。入会と決済、日報の提出、提出物の提出と確認、質問と回答、休会と退会などが当たる。
2. JavaScriptが動かないと確かめられない振る舞い。

それ以外は次の層に書く。

| 確かめたいこと | 書く場所 |
| --- | --- |
| ログイン必須、役割ごとの権限、リダイレクト | `test/integration/` または `test/controllers/` |
| 入力検証、並び順、絞り込み、集計 | `test/models/`、`test/queries/` |
| 通知が作られること、宛先、文面 | `test/models/`、`test/notifiers/`、`test/deliveries/`、`test/mailers/` |
| JavaScriptの変換や判定（Markdownの変換、タグ名の検証など、DOMに頼らない処理） | `test/javascript/*.mjs`（`node --test`。CIが実行するのは拡張子 `.mjs` のファイルだけ） |
| サーバーが描画する表示 | `BrowserlessSystemTestCase`、`test/components/`、`test/integration/` |
| コメント、ブックマーク、タグ、リアクション、Watchなどの共通部品 | 操作は1つの対象でだけ確かめる。ほかの対象は表示だけを確かめる |

次のテストは書かない。既にあるものは消す。

- 下の層のテストと同じことを確かめているテスト。
- Railsやライブラリーそのものの動作を確かめているテスト。
- 同じ流れを、役割や対象だけ変えて繰り返すテスト。違いは下の層で、役割や対象を並べて確かめる。

システムテストの書き方として、次を守る。

- 要素がないことは `assert_no_selector` や `assert_no_text` などで確かめる。`assert_not has_button?` のように「あること」の判定を否定すると、待ち時間の上限（15秒）まで待つ。
- 非表示のチェックボックスは、ラベルをクリックして操作する。
- 1件で10秒を超えるテストは、原因を調べて直す。

既存のテストを消す、または移すときは、次の手順を取る。

1. [削減候補の一覧](../test_reduction_candidates.md)に、対象と根拠を書く。
2. 移す場合は、下の層のテストが同じ内容を確かめていることを確認する。足りなければ先に追加する。
3. 「一度も失敗していない」ことだけを理由に消さない。重複、自明、対象がもうない、のどれかを示す。
4. ディレクトリーや機能のまとまりごとにPRを分け、テスト時間の記録（[CIのテスト時間の計測](../ci_test_timings.md)）で効果を確かめる。

## 検討した案

- **現状のまま、並列数を増やす**: テストの総量が変わらないため、ランナーの時間と手元での実行時間は減らない。準備時間が並列数だけ増える。
- **システムテストをほぼ全部やめ、人手の確認に切り替える**: 37signalsがHEYで取った方法である。このプロジェクトは変更する人が多く入れ替わるため、主要な流れの自動確認は残す。
- **変更に関係するテストだけを走らせる**: Shopifyなどの方法である。テストとファイルの対応を記録する仕組みが必要になる。先に総量を減らし、そのあとで検討する。
- **ブラウザーなしのテストへ移すだけにする**: 2026-11-17に、操作をしないテストのうちrack_testで通るものは移してある。残りはJavaScriptでの描画に頼っており、同じ方法ではこれ以上移せない。

## 結果・影響

- システムテストの件数と時間が減り、CIと手元での確認が速くなる。
- 権限や入力検証の網羅を下の層で行うため、組み合わせを増やしてもテスト時間が伸びにくい。
- 画面の細かい表示の崩れは、自動テストでは見つけにくくなる。主要な流れのシステムテストと、レビュー時の動作確認で補う。
- 既存のテストを移す作業が発生する。一度に行わず、候補の一覧に沿って進める。
- レビューでは、新しいシステムテストがこの基準に当てはまるかを確認する。

## 関連資料

- [削減候補の一覧](../test_reduction_candidates.md)
- [CIのテスト時間の計測](../ci_test_timings.md)
- [system tests have failed（DHH）](https://world.hey.com/dhh/system-tests-have-failed-d90af718)
- [systematic system tests considered harmful（Jorge Manrubia）](https://world.hey.com/jorge/systematic-system-tests-considered-harmful-867f22c8)
- [Write tests. Not too many. Mostly integration.（Kent C. Dodds）](https://kentcdodds.com/blog/write-tests)
- [Just Say No to More End-to-End Tests（Google Testing Blog）](https://testing.googleblog.com/2015/04/just-say-no-to-more-end-to-end-tests.html)
- [Magic Tricks of Testing（Sandi Metz）](https://speakerdeck.com/skmetz/magic-tricks-of-testing-railsconf)
- [Spark Joy by Running Fewer Tests（Shopify）](https://shopify.engineering/spark-joy-by-running-fewer-tests)
