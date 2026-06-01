# Bootcamp API

Bootcamp の API 仕様は OpenAPI 3.1 形式で `docs/openapi.yaml` にまとめています。

外部向けの閲覧用ドキュメントは Swagger UI で `public/api-docs/` に生成します。

```bash
npm run build:openapi-docs
```

生成後はローカルで `http://localhost:3000/api-docs/` から確認できます。本番環境でも静的ファイルとして `/api-docs/` から参照できます。公開用の生成物は本番の静的配信対象にするためコミットし、`npm run lint:openapi` で `docs/openapi.yaml` と `public/api-docs/` の同期を確認します。

構文と基本構造の確認:

```bash
npm run lint:openapi
```

この仕様は `/api` 配下の Rails routes を入口一覧として機械可読にするための初期版です。レスポンス schema は代表的な共通形から始めているため、詳細な属性は `app/views/api/**/*.jbuilder` と `test/integration/api/**/*_test.rb` を根拠に順次拡充してください。
