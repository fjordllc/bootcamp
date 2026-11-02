# リポジトリのガイドライン

## プロジェクト構成とモジュール
- `app/` はRailsアプリのコードです。`models/`、`controllers/`、`views/`、`jobs/`、`helpers/` と、フロントエンドの `javascript/`（Shakapacker）が含まれます。
- `config/` には環境設定、ルーティング、lint設定があります（`.rubocop.yml`、`config/slim_lint.yml` を参照）。
- `db/` にはマイグレーションとスキーマがあります。`lib/` はアプリ固有のユーティリティ、`public/` は静的アセットです。
- `test/` はMinitestのテスト一式です。`system/`、`models/`、`controllers/` と、`test/fixtures/` のfixtureが含まれます。
- `bin/` には補助スクリプトがあります。`Procfile.dev` はRailsとアセット開発サーバーを起動します。

## ビルド、テスト、開発用コマンド
- セットアップ: `bin/setup` — gemのインストール、DBの準備、npmなどを行います。
- 開発時の起動: `foreman start -f Procfile.dev` — Railsを `:3000` で起動し、Shakapackerも起動します。
- テスト（ヘッドレス）: `rails test:all`。
- テスト（ブラウザー）: `HEADFUL=1 rails test:all`。
- テスト（並列実行なし）: `PARALLEL_WORKERS=1 rails test:all`。
- lint: `./bin/lint` — RuboCop（自動修正あり）、Slim-Lint、ESLint/Prettierを実行します。
- プロファイラー: rack-mini-profilerを有効にするには `PROFILE=1 rails server` を実行します。

## コーディングスタイルと命名規則
- Ruby: インデントは2スペース、メソッド名はsnake_case、クラス名はCamelCaseとします。RuboCop（`.rubocop.yml`）で検査します。
- View: Slimテンプレートを使い、`config/slim_lint.yml` でlintします。
- JS/TS: コードは `app/javascript/` に置きます。`npm run lint` スクリプトでESLintとPrettierを実行します。React 18とShakapacker/Webpack 5を使います。
- ファイルはRailsの規約に従います（例: `app/models/user.rb`、テストの `test/models/user_test.rb`）。

## テストのガイドライン
- フレームワーク: システムテストにMinitestとCapybaraを使います。
- 構成: 単体テストと統合テストは対応する `test/*` ディレクトリに置き、ファイル名は `*_test.rb` とします。
- テストを1件または特定の行だけ実行するには `rails test test/models/user_test.rb:42` を使います。
- テストは決定的に実行できるようにし、fixtureには `test/fixtures/` を使います。

## コミットとプルリクエストのガイドライン
- コミット: 命令形で、対象範囲を絞ります。issue番号を記載します（例: "プロフィールの入力検証を修正する #123"）。
- コミットの件名と本文は日本語で書く必要があります。技術名とファイルパスは元の表記のままでもかまいません。
- PR: 説明を明確にし、関連issueをリンクします。UI変更ではスクリーンショットを添え、該当する場合はマイグレーションの説明とロールバック計画を記載します。
- 品質基準: すべてのlinterを通し（`bin/lint`）、CI（GitHub Actions）を成功させます。動作を変更する場合はテストを追加または修正します。

## セキュリティと設定のヒント
- 秘密情報をコミットしてはいけません。`.env.local` を使います。`.ruby-version`、`.tool-versions` と `.node-version`/`.nvmrc` に記載されたNodeのバージョンに従います。
- ローカルDBと依存関係の準備には `bin/setup` を使います。相談せずに `config/` を手動変更するのは避けてください。

## エージェント固有の指示
- 編集時はこのガイドラインに従ってください。変更を最小限にし、作業範囲を依頼内容に限定します。コマンドを追加したり動作を変更したりする場合は、ドキュメントやテストも更新します。

## 設計判断の記録
- 重要な設計判断は、[設計判断の記録（ADR）](docs/adr/README.md)に従い、背景と理由を日本語で記録します。日常的な修正すべてにADRを書く必要はありません。
- 同じ領域を変更する前に、関連する既存ADRを読んで判断の経緯を確認します。

## コードレビュー
- このリポジトリをレビューするとき、またはPRレビューへの返信を作成・改訂するときは、利用できる場合、個人用の `bootcamp-code-review` skill（`~/.codex/skills/bootcamp-code-review/SKILL.md`）を読み、その内容に従ってください。再レビューも対象です。自動のskill選択だけに頼らないでください。
- Railsモデルを分割する場合: 独立した責務にはまずPOROを検討します。関連するモデル宣言と振る舞いを一緒にしたほうが明確なら、複数モデルでの再利用がなくてもConcernを使えます。根拠が曖昧な分割や行数だけを基準にした分割はモデルに戻します。Concernを一律にPOROへ変換することを求めてはいけません。
- 以前のレビューコメントと現在の差分を照合します。必須の修正と任意の好みを分け、振る舞いを保ち、ユーザーの明示的な承認がある場合に限って公開します。

## エラー処理ドキュメント（必須）
- 実装、バグ修正、リファクタリング、レビューを始める際は毎回、[docs/error_handling.md](docs/error_handling.md) と [docs/rails_error_handling.md](docs/rails_error_handling.md) を読みます。
- エラー処理、通知、監視を変更する場合は、[Tokyo RubyKaigi 12のスライド](https://speakerdeck.com/morihirok/hun-dun-tositali-wai-chu-li-toerajian-shi-nizhi-xu-womotarasu)の該当ページと照らし合わせ、プロジェクト固有の意図的な例外があれば、正確に記録します。
