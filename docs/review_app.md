# Review Appの失敗時の確認

Review AppはPR更新時にGitHub Actionsの`Review App`からCloud Buildを開始します。アプリの通常のCIと、Review Appのビルド・DB準備・デプロイは別の結果です。CIが成功してもReview Appが成功したとは限りません。

## DB再作成の前提条件

`CreateDB`は`WaitForProxy`と`WriteSubstitutionEnv`の両方の成功を待ちます。プロキシの起動・接続確認と環境変数ファイルの生成は並列のままです。環境変数ファイルを生成できなかったときに、既存PRのDBだけを先に削除することを防ぎます。SDK同梱Pythonの起動を修正した後も、API権限やサービス障害などで環境生成は失敗し得ます。DB操作の自動再試行は行いません。

## GitHub Actionsで確認できる情報

状態確認には`.cloudbuild/review-cloud-build-status`を使います。引数は小文字のUUID形式のbuild IDだけで、projectは`bootcamp-224405`、regionは`asia-northeast1`に固定しています。

| 終了コード | 意味 | workflowの扱い |
| --- | --- | --- |
| 0 | 明示的な`SUCCESS` | 成功 |
| 3 | `PENDING` / `QUEUED` / `WORKING` | 既存の上限120回・30秒間隔で確認を続ける |
| 1 | `FAILURE` / `CANCELLED` / `TIMEOUT` / `INTERNAL_ERROR` / `EXPIRED` | 失敗 |
| 2 | API・認証等の読み取り失敗、空・不正・未知の状態、引数不正 | 失敗。待機や成功へ変換しない |

build ID、固定project/regionから生成したコンソールリンク、状態を表示します。ビルド失敗時だけ追加で`id,status,steps[].id,steps[].status,steps[].exitCode`をJSON projectionで取得し、失敗stepのID・状態・終了コードを表示します。終了コードがない場合は`unavailable`です。取得不能や不正な診断データは`diagnostics unavailable`と表示し、元のビルド失敗を維持します。失敗stepがない場合もコンソールで確認します。

失敗確定後の追加診断のgcloud呼び出しには、内部固定の10秒の制限があります。期限を超えた子プロセスは終了・回収し、固定の診断不能メッセージだけを表示して元の終了コード1を返します。この制限は環境変数で変更できません。最初の状態取得やworkflowの待機回数・間隔は変更しません。

診断JSONは256 KiB・1000 step以下、表示するstep IDはASCII英数字・`_`・`.`・`-`で100文字以下、終了コードは32 bit整数に限定します。状態は既知の列挙値だけを扱います。制御文字や不正値を含む診断は表示しません。substitutions・env・args・レスポンス全体・実ログ・gcloudの生stderrは出力しません。これらには秘密情報が含まれ得るため、調査時にもそのまま貼り付けないでください。

API読み取り失敗は認証・アクセス権・サービス状態を確認します。内部stepの失敗は、権限のある担当者がコンソールリンクから該当stepを調べます。この変更は失敗の封じ込めと調査情報の改善であり、外部障害やアプリのエラーをすべて解消するものではありません。過去の失敗すべてがPython起動不備に起因したとは確認できていません。

## エラー処理の位置づけ

[エラー処理](error_handling.md)と[Tokyo RubyKaigi 12のスライド43、67〜73枚目](https://speakerdeck.com/morihirok/hun-dun-tositali-wai-chu-li-toerajian-shi-nizhi-xu-womotarasu)の方針に従い、ビルド失敗・読み取り失敗・不正データを成功として続行しません。既にビルド失敗が確定した後の診断JSONの検証エラーと追加読み取りの期限超過は、秘密情報を含み得る例外本文を出さず、診断不能として明示します。これは追加診断の境界で元の失敗を保存する処理です。一般の想定外例外を捕捉して処理を続けるものではありません。アプリのRollbar通知や監視閾値は変更しません。
