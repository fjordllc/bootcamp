# Bootcamp API

Bootcamp の API 仕様は OpenAPI 3.1 形式で `docs/openapi.yaml` にまとめています。

外部向けの閲覧用ドキュメントは Swagger UI で `public/api-docs/` に生成します。生成処理は Ruby スクリプトで行い、Swagger UI の配布ファイルは `swagger-ui-dist` からコピーします。

```bash
npm run build:openapi-docs
```

生成後はローカルで `http://localhost:3000/api-docs/` から確認できます。本番環境でも静的ファイルとして `/api-docs/` から参照できます。公開用の生成物は本番の静的配信対象にするためコミットし、`npm run lint:openapi` で `openapi_parser` gem による `docs/openapi.yaml` の検証と、`public/api-docs/` の同期を確認します。

構文と基本構造の確認:

```bash
npm run lint:openapi
```

この仕様は `/api` 配下の Rails routes を入口一覧として機械可読にするための初期版です。レスポンス schema は代表的な共通形から始めているため、詳細な属性は `app/views/api/**/*.jbuilder` と `test/integration/api/**/*_test.rb` を根拠に順次拡充してください。

## お知らせ・イベント予定の読み取りAPI

- `GET /api/announcements` と `GET /api/events`（それぞれ `.json` 付きも可）はJSONのみを返します。詳細取得や作成・更新・削除のAPIは追加しません。
- `API::BaseController` の既存認証を使います。有効なセッション、APIのJWT、または通常のOAuth `read` が必要です。inactive利用者は401、`read` のないOAuthは403、MCP用アプリまたはMCP scopeのトークンは401です。匿名公開APIではありません。
- 利用者・主催者・参加者の属性は返さず、足跡を記録しません。本文内の記述を匿名化するAPIではないため、認証済みで読めることを公開画面への再配布許可と解釈しないでください。
- 共通パラメーターは `page`（既定1、1〜1,000,000）と `per_page`（既定20、1〜100）。正の10進整数のみで、先頭の0・負数・小数・空文字・配列・オブジェクト・上限超過は400です。巨大な整数文字列は変換前に拒否します。
- 応答は `{ "announcements": [...], "total_pages": N }` または `{ "events": [...], "total_pages": N }`。範囲外ページは空配列、全件が0なら `total_pages: 0`。ページ間でデータが更新される場合のスナップショット整合性は保証しません。

### お知らせ

`wip: false`、`published_at` が存在し現在時刻以下のものだけを、`published_at DESC, id DESC` で返します。
各項目は `id`、`title`、Markdown原文の `description`、ISO8601の `published_at`、`target`、Bootcamp内相対パスの `url` です。
`target` は `all` / `students` / `job_seekers` の**通知先分類**で、閲覧権限ではありません。既存ダッシュボードと同様にtargetで絞りません。

### イベント予定

`from` / `to` は厳密な `YYYY-MM-DD`（0001〜9999年）。Tokyoの日付で両端を含み、省略時は今日〜6日後の7日間です。`from` のみならそこから7日間、`to` のみなら今日からその日までです。
逆順、不正日、日時・タイムゾーン付き文字列、配列・オブジェクト、32日以上は400にし、無制限の将来展開は行いません。

- 特別イベントは期間と重なる、WIPでなく `end_at > now` のものです。前日に始まった開催中イベントも含み、`to` の翌日0時ちょうどに開始するものや `from` の0時ちょうどに終了するものは含みません。
- 定期イベントはWIP・finishedを除外し、`RegularEvent#all_scheduled_dates(from:, to:)` により期間内の発生回を取得します。毎週、第1〜第4、ISO週番号の奇数・偶数ルールを複製しません。終了判定も既存の `ended?` を使い、開催中を含み終了時刻ちょうどから除外します。
- 既存ダッシュボードと同じ `UpcomingEvent#held_on_scheduled_date?` で祝日・個別休みを `held: false` として残します。取消一般を意味する `cancelled` には変換しません。
- 順序は `start_at ASC, kind ASC, id ASC`。`kind` は `event` / `regular_event`、`id` は元レコードのIDです。`kind + id + start_at` で発生回を識別できます。
- 各項目は `kind`、`id`、`title`、相対パスの `url`、発生回の `start_at` / `end_at`（ISO8601、Tokyoの `+09:00`）、`held` のみです。

設計の理由は [ADR 0002](adr/0002-read-only-announcement-event-api.md) を参照してください。

## 個人アクセストークン

メンターと管理者は、ログイン後に `/current_user/access_tokens` で個人アクセストークンを発行できます。スクリプトなどからAPIを使う場合は、OAuthアプリケーションを作らずにこのトークンを利用できます。

- `read` は常に付与されます。`write`・`mentor`・`admin` は発行時に選びます（`mentor` はメンターと管理者、`admin` は管理者のみ）。
- 有効期限は30日・90日・365日から選びます。
- トークンの値は発行直後の画面でだけ表示されます。不要になったトークンは同じ画面で失効させてください。

```bash
curl -X PATCH https://bootcamp.fjord.jp/api/practices/1.json \
  -H "Authorization: Bearer $BOOTCAMP_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"practice": {"description": "更新する本文"}}'
```

判断の背景は[ADR 0003](adr/0003-personal-access-tokens.md)を参照してください。
