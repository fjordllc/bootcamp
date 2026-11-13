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

## 専用の読み取り連携でのOAuth更新

アクセストークンの有効期間は7200秒です。更新トークンの初回発行は既定で無効です。Classroomなど、サーバー側でclient secretを保管できる読み取り専用の連携に限り、次の条件をすべて満たすと初回発行を許可します。

- Bootcamp側の環境変数`BOOTCAMP_REFRESH_CLIENT_UID`に、専用OAuth applicationのUIDを1つだけ設定する。空値、前後の空白、複数UIDの列挙は指定しない。
- MCP用ではないapplicationをconfidentialにし、登録するscopeを`read`だけにする。
- 利用者がauthorization codeフローで認可し、発行するトークンのscopeも`read`だけにする。

UIDは完全一致で判定します。設定がない場合や一致しない場合、public client、MCP用application（UIDを指定した場合も含む）、client credentialsフロー、`write`・`mentor`・`admin`を含むapplicationや認可には更新トークンを発行しません。既存の共用クライアントやドキュメント保守用クライアントを指定せず、専用クライアントを用意してください。

### 更新と失効

`POST /oauth/token`に`grant_type=refresh_token`、現在の`refresh_token`、`client_id`、`client_secret`をフォーム形式で送ります。scopeは省略して元の`read`を引き継ぎます。scopeの拡大は拒否され、更新後もアクセストークンの有効期間は7200秒です。アクセストークンが期限切れになっても、失効していない更新トークンは更新に使えます。

Doorkeeper 5.8.2と現在のスキーマでは、更新のたびに新しいアクセストークンと更新トークンを発行します。旧トークンは更新した時点では失効せず、**新しいアクセストークンがAPIで初めて認証された時点**で、対応する旧アクセス・更新トークンが失効します。それまでは旧更新トークンの再送も成功します。更新を直列化し、新しいトークンの組を安全に保存してから使用し、以降は新しい更新トークンだけを使ってください。更新トークン自体に固定の有効期限はありません。

停止・漏えい時は、client credentials付きで`POST /oauth/revoke`へ`token=<refresh_token>`と`token_type_hint=refresh_token`を送り、対象トークンを明示的に失効させます。失効した更新トークンは`invalid_grant`で拒否されます。再送や複数の認可により有効なトークンが複数残っている場合は、停止対象のapplicationに属する有効なトークンをすべて失効させてください。1件の失効が他の更新系列にも伝播するとは限りません。

失効には利用者のブラウザーセッションは不要です。別クライアントの資格情報による失効は403で拒否し、対象のトークンは失効しません。有効なclient credentialsで存在しないトークンを送った場合は、Doorkeeper標準のRFC 7009の応答として200と空のJSONオブジェクトを返します。既存の`McpOauth::TokensController`はSorceryのブラウザー活動記録だけを除外し、トークンの認証・失効処理はDoorkeeperに任せます。

`BOOTCAMP_REFRESH_CLIENT_UID`の削除・変更で止まるのは**新規発行だけ**です。すでに発行した更新トークンの更新はDoorkeeper標準の処理が続けます。連携を止めるときは、先に対象トークンをすべて失効させ、その後に環境変数やクライアント設定を解除してください。

### 有効化前の確認

デプロイと有効化は、それぞれ別途承認を得てから行います。

本番で有効化する際は、Cloud Buildの本番トリガーの置換変数`_BOOTCAMP_REFRESH_CLIENT_UID`に、同じ専用の読み取り専用クライアントのUIDを設定します。既存の`.cloudbuild/cloud-build-env`が先頭の`_`を除いて`BOOTCAMP_REFRESH_CLIENT_UID`として出力するため、パイプラインの変更は不要です。デプロイは生成した環境変数ファイルを`--env-vars-file`で渡して環境変数を置き換えるため、Cloud Runサービスだけに`--update-env-vars`で設定しても次回デプロイで失われます。未設定・空値では更新トークンを新規発行しません。非本番環境は、別途承認されるまでこの設定を未設定のままにします。

この機能には、Bootcamp側へのコードのデプロイと環境変数の反映が必要です。その後、専用クライアントで利用者の認可を新しく取得してください。既発行のアクセストークンに更新トークンが追加されることはありません。連携側でclient secret・トークンの安全な保存、更新の直列化、更新後の保存とAPI呼び出し、失効手順を確認してから運用を始めます。この変更だけではデプロイ、クライアント作成、認可、環境変数の設定は行いません。

判断の背景は[読み取り専用OAuthクライアントに更新トークンを限定するADR](adr/0004-limit-oauth-refresh-to-opted-in-read-client.md)を参照してください。
