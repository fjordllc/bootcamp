# 管理者パフォーマンス画面の運用

この変更だけではGoogleの設定や本番の計測は有効になりません。ホストエージェント、計測値のDBテーブル、外部テレメトリーサービスは使いません。成功した許可ページのRails処理時間と、ブラウザーから受信できた初回文書の最新LCP/INP/CLSを、bare JSON STDOUT → Cloud Loggingの5メトリクス → Cloud Monitoring集計 → 管理ページの順で読みます。

## 有効化前の設定

両フラグは既定で無効です。文字列`true`だけが有効になります。

| 環境変数 | 設定 |
| --- | --- |
| PERFORMANCE_COLLECTION_ENABLED | STDOUT収集とブラウザーチケット発行。既定false |
| PERFORMANCE_DASHBOARD_ENABLED | 管理画面からのMonitoring読み取り。既定false |
| PERFORMANCE_PROJECT_ID | 計測対象のGoogle project ID（推測しない） |
| PERFORMANCE_CLOUD_RUN_SERVICE | 対象Cloud Runサービス名 |
| PERFORMANCE_CLOUD_RUN_REGION | 対象リージョン |
| PERFORMANCE_COLLECTION_STARTED_AT | 本番収集を開始したRFC3339 UTC日時。例`2026-11-01T00:00:00Z`。実際の切替日時を使う |
| APP_HOST_NAME | 既存の公開ホスト名。収集はこのホストのHTTPS Originと一致するCookieセッションだけを受理 |

稼働中の共有SolidCacheテーブル・保存容量とPostgreSQL advisory lockを確認します。既存設定と同じnamespace/store optionsの専用ストアを使い、LocalCacheを介しません。キャッシュ障害は収集・読み取りを止めます。通常ページではGoogleに接続しません。起動・HTTPリクエストからGoogleリソースを作成しません。

Cloud Runに付与したサービスアカウントのADCを使います。`GOOGLE_APPLICATION_CREDENTIALS`を追加したり、Storage用のダウンロード鍵を流用しません。スコープは`https://www.googleapis.com/auth/monitoring.read`です。

運用担当者が別の権限で`logging.googleapis.com`と`monitoring.googleapis.com`を有効にし、下記メトリクスを収集前に作成します。運用者には`roles/logging.configWriter`またはlogMetrics create/get/update相当と、必要なservice usage権限が必要です。実行アカウントには`monitoring.timeSeries.list`・`monitoring.metricDescriptors.get`だけのカスタムロールが最小です。広い代替は`roles/monitoring.viewer`であり、対象プロジェクトの他のモニタリング情報も読めます。役割の最新定義を確認し、既存のStorage等のIAMを置き換えずに追加してください。実行側にログ閲覧・ログ設定編集・metric writer・Trace・Cloud SQL権限は不要です。

## 5メトリクスを生成・作成する

正本は`Performance::MetricSpecs`と`Performance::Pages`です。ページ・端末幅・metric/stateのallowlist、名前・単位・bounds・extractorを一緒に生成します。以下はローカルJSON生成だけです。Googleの作成コマンドは運用担当者が対象プロジェクトとdiffを確認して実行します。既存メトリクスのkind/valueTypeは変更できません。境界やスキーマ変更時はv2名で別途切替を設計します。

```bash
# デプロイ先の設定が入った環境で、認証情報を出力せずにテンプレートを作る
bin/rails runner 'c = Performance::Configuration.new; abort "invalid identity" unless c.valid_identity?; Performance::MetricSpecs::SPECS.each_key { |m| s = Performance::MetricSpecs.template(m, c); File.write("/tmp/#{s[:name]}.json", JSON.pretty_generate(s)) }'

# オペレーター専用。権限・対象・料金を確認してから実行（アプリは実行しない）
gcloud services enable logging.googleapis.com monitoring.googleapis.com --project="$PERFORMANCE_PROJECT_ID"
for name in bootcamp_perf_server_ms_v1 bootcamp_perf_lcp_ms_v1 bootcamp_perf_inp_ms_v1 bootcamp_perf_cls_v1 bootcamp_perf_browser_observations_v1; do
  gcloud logging metrics create "$name" --project="$PERFORMANCE_PROJECT_ID" --config-from-file="/tmp/$name.json"
done
```

以下の5JSONは同じ生成コードの出力です。`PROJECT_ID`・`SERVICE`・`REGION`は例示用の置換箇所です。Cloud Runのcontainer stdoutがjsonPayloadになることを実機で確認してください。ログの文面からページを抽出しません。ログは全て512 bytes未満です。

### bootcamp_perf_server_ms_v1

```json
{
  "name": "bootcamp_perf_server_ms_v1",
  "description": "Bootcamp performance schema 1: server",
  "filter": "resource.type=\"cloud_run_revision\" AND resource.labels.project_id=\"PROJECT_ID\" AND resource.labels.service_name=\"SERVICE\" AND resource.labels.location=\"REGION\" AND logName=\"projects/PROJECT_ID/logs/run.googleapis.com%2Fstdout\" AND jsonPayload.event=\"bootcamp_performance\" AND jsonPayload.schema=1 AND (jsonPayload.page=\"dashboard\" OR jsonPayload.page=\"reports_index\" OR jsonPayload.page=\"reports_show\" OR jsonPayload.page=\"products_index\" OR jsonPayload.page=\"products_show\" OR jsonPayload.page=\"questions_index\" OR jsonPayload.page=\"questions_show\" OR jsonPayload.page=\"practice_show\" OR jsonPayload.page=\"users_index\" OR jsonPayload.page=\"users_show\") AND jsonPayload.kind=\"server\" AND jsonPayload.duration_ms:*",
  "metricDescriptor": {
    "metricKind": "DELTA",
    "valueType": "DISTRIBUTION",
    "unit": "ms",
    "labels": [
      {
        "key": "page",
        "valueType": "STRING"
      }
    ]
  },
  "labelExtractors": {
    "page": "EXTRACT(jsonPayload.page)"
  },
  "valueExtractor": "EXTRACT(jsonPayload.duration_ms)",
  "bucketOptions": {
    "explicitBuckets": {
      "bounds": [
        0,
        50,
        100,
        200,
        300,
        400,
        500,
        600,
        750,
        1000,
        1250,
        1500,
        2000,
        3000,
        5000,
        10000,
        30000,
        60000
      ]
    }
  }
}
```

### bootcamp_perf_lcp_ms_v1

```json
{
  "name": "bootcamp_perf_lcp_ms_v1",
  "description": "Bootcamp performance schema 1: LCP",
  "filter": "resource.type=\"cloud_run_revision\" AND resource.labels.project_id=\"PROJECT_ID\" AND resource.labels.service_name=\"SERVICE\" AND resource.labels.location=\"REGION\" AND logName=\"projects/PROJECT_ID/logs/run.googleapis.com%2Fstdout\" AND jsonPayload.event=\"bootcamp_performance\" AND jsonPayload.schema=1 AND (jsonPayload.page=\"dashboard\" OR jsonPayload.page=\"reports_index\" OR jsonPayload.page=\"reports_show\" OR jsonPayload.page=\"products_index\" OR jsonPayload.page=\"products_show\" OR jsonPayload.page=\"questions_index\" OR jsonPayload.page=\"questions_show\" OR jsonPayload.page=\"practice_show\" OR jsonPayload.page=\"users_index\" OR jsonPayload.page=\"users_show\") AND jsonPayload.kind=\"browser\" AND (jsonPayload.device=\"desktop\" OR jsonPayload.device=\"mobile\") AND jsonPayload.metric=\"LCP\" AND jsonPayload.state=\"observed\" AND jsonPayload.value:*",
  "metricDescriptor": {
    "metricKind": "DELTA",
    "valueType": "DISTRIBUTION",
    "unit": "ms",
    "labels": [
      {
        "key": "page",
        "valueType": "STRING"
      },
      {
        "key": "device",
        "valueType": "STRING"
      }
    ]
  },
  "labelExtractors": {
    "page": "EXTRACT(jsonPayload.page)",
    "device": "EXTRACT(jsonPayload.device)"
  },
  "valueExtractor": "EXTRACT(jsonPayload.value)",
  "bucketOptions": {
    "explicitBuckets": {
      "bounds": [
        0,
        100,
        250,
        500,
        1000,
        1500,
        2000,
        2250,
        2500,
        2750,
        3000,
        3500,
        4000,
        4500,
        5000,
        6000,
        8000,
        10000,
        15000,
        30000,
        60000
      ]
    }
  }
}
```

### bootcamp_perf_inp_ms_v1

```json
{
  "name": "bootcamp_perf_inp_ms_v1",
  "description": "Bootcamp performance schema 1: INP",
  "filter": "resource.type=\"cloud_run_revision\" AND resource.labels.project_id=\"PROJECT_ID\" AND resource.labels.service_name=\"SERVICE\" AND resource.labels.location=\"REGION\" AND logName=\"projects/PROJECT_ID/logs/run.googleapis.com%2Fstdout\" AND jsonPayload.event=\"bootcamp_performance\" AND jsonPayload.schema=1 AND (jsonPayload.page=\"dashboard\" OR jsonPayload.page=\"reports_index\" OR jsonPayload.page=\"reports_show\" OR jsonPayload.page=\"products_index\" OR jsonPayload.page=\"products_show\" OR jsonPayload.page=\"questions_index\" OR jsonPayload.page=\"questions_show\" OR jsonPayload.page=\"practice_show\" OR jsonPayload.page=\"users_index\" OR jsonPayload.page=\"users_show\") AND jsonPayload.kind=\"browser\" AND (jsonPayload.device=\"desktop\" OR jsonPayload.device=\"mobile\") AND jsonPayload.metric=\"INP\" AND jsonPayload.state=\"observed\" AND jsonPayload.value:*",
  "metricDescriptor": {
    "metricKind": "DELTA",
    "valueType": "DISTRIBUTION",
    "unit": "ms",
    "labels": [
      {
        "key": "page",
        "valueType": "STRING"
      },
      {
        "key": "device",
        "valueType": "STRING"
      }
    ]
  },
  "labelExtractors": {
    "page": "EXTRACT(jsonPayload.page)",
    "device": "EXTRACT(jsonPayload.device)"
  },
  "valueExtractor": "EXTRACT(jsonPayload.value)",
  "bucketOptions": {
    "explicitBuckets": {
      "bounds": [
        0,
        16,
        40,
        80,
        120,
        160,
        200,
        240,
        300,
        400,
        500,
        600,
        800,
        1000,
        1500,
        3000,
        10000,
        60000
      ]
    }
  }
}
```

### bootcamp_perf_cls_v1

```json
{
  "name": "bootcamp_perf_cls_v1",
  "description": "Bootcamp performance schema 1: CLS",
  "filter": "resource.type=\"cloud_run_revision\" AND resource.labels.project_id=\"PROJECT_ID\" AND resource.labels.service_name=\"SERVICE\" AND resource.labels.location=\"REGION\" AND logName=\"projects/PROJECT_ID/logs/run.googleapis.com%2Fstdout\" AND jsonPayload.event=\"bootcamp_performance\" AND jsonPayload.schema=1 AND (jsonPayload.page=\"dashboard\" OR jsonPayload.page=\"reports_index\" OR jsonPayload.page=\"reports_show\" OR jsonPayload.page=\"products_index\" OR jsonPayload.page=\"products_show\" OR jsonPayload.page=\"questions_index\" OR jsonPayload.page=\"questions_show\" OR jsonPayload.page=\"practice_show\" OR jsonPayload.page=\"users_index\" OR jsonPayload.page=\"users_show\") AND jsonPayload.kind=\"browser\" AND (jsonPayload.device=\"desktop\" OR jsonPayload.device=\"mobile\") AND jsonPayload.metric=\"CLS\" AND jsonPayload.state=\"observed\" AND jsonPayload.value:*",
  "metricDescriptor": {
    "metricKind": "DELTA",
    "valueType": "DISTRIBUTION",
    "unit": "1",
    "labels": [
      {
        "key": "page",
        "valueType": "STRING"
      },
      {
        "key": "device",
        "valueType": "STRING"
      }
    ]
  },
  "labelExtractors": {
    "page": "EXTRACT(jsonPayload.page)",
    "device": "EXTRACT(jsonPayload.device)"
  },
  "valueExtractor": "EXTRACT(jsonPayload.value)",
  "bucketOptions": {
    "explicitBuckets": {
      "bounds": [
        0,
        0.01,
        0.025,
        0.05,
        0.075,
        0.1,
        0.125,
        0.15,
        0.2,
        0.25,
        0.3,
        0.4,
        0.5,
        1,
        2,
        5,
        10,
        100
      ]
    }
  }
}
```

### bootcamp_perf_browser_observations_v1

```json
{
  "name": "bootcamp_perf_browser_observations_v1",
  "description": "Bootcamp performance schema 1: coverage",
  "filter": "resource.type=\"cloud_run_revision\" AND resource.labels.project_id=\"PROJECT_ID\" AND resource.labels.service_name=\"SERVICE\" AND resource.labels.location=\"REGION\" AND logName=\"projects/PROJECT_ID/logs/run.googleapis.com%2Fstdout\" AND jsonPayload.event=\"bootcamp_performance\" AND jsonPayload.schema=1 AND (jsonPayload.page=\"dashboard\" OR jsonPayload.page=\"reports_index\" OR jsonPayload.page=\"reports_show\" OR jsonPayload.page=\"products_index\" OR jsonPayload.page=\"products_show\" OR jsonPayload.page=\"questions_index\" OR jsonPayload.page=\"questions_show\" OR jsonPayload.page=\"practice_show\" OR jsonPayload.page=\"users_index\" OR jsonPayload.page=\"users_show\") AND jsonPayload.kind=\"browser\" AND (jsonPayload.device=\"desktop\" OR jsonPayload.device=\"mobile\") AND (jsonPayload.metric=\"LCP\" OR jsonPayload.metric=\"INP\" OR jsonPayload.metric=\"CLS\") AND (jsonPayload.state=\"observed\" OR jsonPayload.state=\"unsupported\" OR jsonPayload.state=\"unobserved\")",
  "metricDescriptor": {
    "metricKind": "DELTA",
    "valueType": "INT64",
    "unit": "1",
    "labels": [
      {
        "key": "page",
        "valueType": "STRING"
      },
      {
        "key": "device",
        "valueType": "STRING"
      },
      {
        "key": "metric",
        "valueType": "STRING"
      },
      {
        "key": "state",
        "valueType": "STRING"
      }
    ]
  },
  "labelExtractors": {
    "page": "EXTRACT(jsonPayload.page)",
    "device": "EXTRACT(jsonPayload.device)",
    "metric": "EXTRACT(jsonPayload.metric)",
    "state": "EXTRACT(jsonPayload.state)"
  }
}
```

## 集計・判定の範囲

- 許可ページはダッシュボード、日報一覧/詳細、提出物一覧/詳細、質問一覧/詳細、プラクティス詳細、ユーザー一覧/詳細の10種類です。GET・有効なログイン・HTML・2xxだけが対象です。LP・API・管理ページ・エラー・リダイレクトは対象外です。
- サーバーは100%の成功HTML応答を記録します。処理時間はRailsのnotification durationで、待ち行列・ネットワーク・エラー率を表しません。目標p95 <=500ms / <=1000ms / >1000msは暫定のBootcamp独自目標で、Googleの基準やSLOではありません。
- ブラウザーは文書ごとに20%を独立に選びます。初回の幅767px以下がモバイル幅、768px以上がPC幅です。物理端末・CrUX分類ではありません。リサイズで群を変更しません。
- web-vitalsのlatest numeric callback値だけを保持し、最初のpagehideで一回送信します。visibilitychangeでは送信しません。最終Observerキューのflushは保証しません。INP未観測や非対応は0に変えず、カウンターで区別します。送信失敗を再試行しません。
- iframe、初期非表示/prerender、bfcache復元、Turboトップレベル遷移、History/popstateは除外します。モバイルOS終了・長時間閲覧・遮断・非対応・収集上限による欠損があります。受信カウンターは訪問数・ユーザー数・配信率ではありません。サンプルはログイン利用者側の自己申告で、改ざん耐性のある利用者評価には使えません。
- 署名票は1時間で失効し、セッションとページを固定します。最大60票/時間/セッション、受理は直近60秒で6件/セッション・60件/全インスタンスです。共有ロックは待たず、競合時は落とします。収集上限の時刻範囲だけを25時間保持し、期間に重なる場合は不完全表示にします（範囲の間の空白も保守的に不完全とする場合があります）。生観測・ユーザーID・URL・DOM・SQLはキャッシュやfeatureイベントに保存しません。
- 読み取りの終端はUTCで`floor((now - 15分) / 1時間)`、始端は24時間前です。反映待ちは15〜75分です。`ALIGN_SUM 3600s`と`REDUCE_SUM`でrevision等を合算し、欠けた時間は単にイベントなしとして扱います。各分位値の平均は取りません。
- 分布のcount/bucketCountsを整数で合算し、p75（ブラウザー）/p95（サーバー）の順位が入る区間を表示します。overflowは「以上」です。区間全体が同じ分類に入るときだけ判定します。LCP 2500/4000ms、INP 200/500ms、CLS .1/.25の境界をまたぐ区間・境界から始まる区間は中立です。
- 20件未満は指標・ページ・幅ごとに判定待ちです。これは暫定的な最低数で、Googleの要件・信頼区間・代表性の保証ではありません。coverageとdistributionのobserved数が不一致、指標欠損、権限/認証/API/スキーマエラー、全24時間未経過、収集上限の場合は全体を良好にしません。既知の要注意/要改善は欠損があっても表示します。
- APIリクエストは最大15回（5指標×2ページまで+空の場合の5descriptor）、pageSize10000、指標ごと10000点まで、4MiB/応答・16MiB/更新。2秒ADCを含め12秒の総予算、open1秒/read・write2秒、Monitoring RESTとページ更新の自動リトライ0、redirectなし（SDK内部のADC探索・更新の試行は単一の外側2秒予算内に限り許容し、期限切れは中立表示。Google/Storageのグローバル認証設定は変更しません）です。期限切れの良好結果は再利用せず、失敗も5分キャッシュします。API呼び出し前に中立の更新中状態を書き込み、初期write失敗では接続せず、最終write失敗でもこの5分予約が残ることで連続呼び出しを防ぎます。descriptorが存在することは1時間キャッシュします。

## ステージングからの確認手順

1. 別ステージングproject/service/regionと、既存共有キャッシュ・DB lock・IAM・課金見積もりを確認します。ログとメトリクスの保持期間・閲覧権限も確認します。
2. 5つのログベースメトリクスを作成し、型・単位・labels・boundsを生成物と比較します。API/IAMを設定します。コードは両フラグfalseでデプロイし、管理画面の未設定とGoogle未接続を確認します。
3. collectionを有効にし、実際のログイン済み初回HTML読み込みを行います。ブラウザーのCSRF付きPOSTと、裸のJSONイベントがCloud LoggingでjsonPayloadになり、固定page/device/metric/stateしか含まれないことを確認します。無操作INPとモバイルpagehideを確認します。トークン・session/user ID・URL・SQLがfeatureログにないことを確認します。既存アクセスログは別の保持・プライバシー対象です。
4. 分布4種類とcounterに実際の点が入るまで待ちます。時刻の遅延を考慮し、UTC正時の24時間queryを実Monitoring APIで確認します。複数revision、疎な時間、明示bounds、observed数の一致、descriptor有無、IAM不許可、stale-cache時の中立表示を確認します。実測値と画面の区間を照合してください。ユニットテストはこのGoogle実機確認を代替しません。
5. dashboard readを有効にして管理者だけが読めること、全10ページ・PC幅/モバイル幅・件数・判定・実集計期間・最終取得を確認します。最低数未満、初期24時間未満、未計測、非対応、境界付近、APIエラーを良好にしないことを確認します。
6. 実際のイベント数/bytes/利用revision数を計測し、本番の見込みを見直します。合意後に本番側のmetricsを先に作り、disabledでデプロイし、実際の`COLLECTION_STARTED_AT`を記録してcollection、観測後にdashboardを有効にします。ここに挙げたGoogle設定・本番有効化はこの実装では実行していません。

## 料金・切り戻し・撤去

継続閲覧でも5分に一度、通常最大288更新/日です。最大2880 timeSeries +1440 descriptor calls/日/サービス（両ページ・descriptor欠落の場合）。閲覧がなければ読み取りなしです。これらは呼び出し回数上限で、金額の保証ではありません。集約250groupは保存元seriesの上限ではなく、resource/revisionやbucketsによって費用が増えます。ブラウザーの最大追加ログは60 batch/分×3=180行/分、各512bytes未満です。サーバーログは成功HTML量に比例し、全件です。Logging保存とuser-defined metrics取り込み・読み取りの現行料金をデプロイ時に確認してください。

両フラグfalseですぐに新規featureイベントとGoogle読み取りを止められます。dashboard有効のままcollectionをfalseにしても「計測を停止しています」の中立表示になり、以前の良好キャッシュを表示せずGoogleを読みません。停止後に収集を再開する際はCOLLECTION_STARTED_ATを実際の再開日時に更新し、24時間未満の期間を明示します。既存キャッシュは期限切れ、Googleデータは設定済み保持期間で失効します。コード削除時は2ルート、layout metadata/module/importmap、subscriber/middleware、ナビを一緒に撤去します。メトリクスやIAMの削除は別途明示的に承認を得た運用作業です。自動削除やmigration rollbackはありません。

## vendored bundleの由来

`vendor/javascript/web-vitals.js`はGoogleChrome公式npmパッケージweb-vitals **5.1.0** の標準`dist/web-vitals.js`（attribution版ではない）を変更せず保存しています。Apache-2.0本文は`web-vitals.LICENSE`に同梱しています。

- tarball: `https://registry.npmjs.org/web-vitals/-/web-vitals-5.1.0.tgz`
- npm integrity: `sha512-ArI3kx5jI0atlTtmV0fWU3fjpLmq/nD3Zr1iFFlJLaqa5wLBkUSzINwBPySCX/8jRyjlmy1Volw1kz1g9XE4Jg==`
- bundle SHA256: `1e96629e5c2431ad7b70184060b21bcde423ef26ea26f515a3e74d5f3820b308`
- request.jsは既存pin0.0.13のFetchRequestを使用し、keepalive・CSRF header・same-origin credentialsを渡します。
- v5は今回レビューした初回文書の計測契約です。最新版という意味ではありません。soft navigationを扱う将来版への更新は別途レビューが必要です。

一次資料: [Cloud Run structured logging](https://cloud.google.com/run/docs/logging)、[log metrics](https://cloud.google.com/logging/docs/logs-based-metrics/distribution-metrics)、[Monitoring timeSeries.list](https://docs.cloud.google.com/monitoring/api/ref_v3/rest/v3/projects.timeSeries/list)、[IAM](https://cloud.google.com/monitoring/access-control)、[現行料金](https://cloud.google.com/products/observability/pricing)、[Web Vitals](https://web.dev/articles/vitals)、[web-vitals v5.1.0](https://github.com/GoogleChrome/web-vitals/tree/v5.1.0)、[request.js v0.0.13](https://github.com/rails/request.js/blob/v0.0.13/src/fetch_request.js)。
