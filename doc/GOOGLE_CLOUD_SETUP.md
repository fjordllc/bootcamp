# Google Cloud認証設定ガイド

## 概要

このアプリケーションはGoogle Cloud AI Platform APIを使用してembeddingを生成します。認証情報は環境変数で設定します。

## 認証方法

### 1. JSONファイルパス指定（推奨）

Google CloudのサービスアカウントJSONファイルのパスを環境変数に設定します。

```bash
export GOOGLE_APPLICATION_CREDENTIALS="/path/to/service-account-key.json"
export GOOGLE_CLOUD_PROJECT="your-project-id"
```

#### .envファイルでの設定例

```bash
# .env
GOOGLE_APPLICATION_CREDENTIALS=/path/to/service-account-key.json
GOOGLE_CLOUD_PROJECT=your-project-id
```

### 2. デフォルト認証の利用

gcloud CLIを使用したデフォルト認証も利用可能です。

```bash
# デフォルト認証の設定
gcloud auth application-default login

# プロジェクトIDの設定
export GOOGLE_CLOUD_PROJECT="your-project-id"
```

### 3. Google Cloud環境での自動認証

Cloud Run、GKE、Compute Engineなどの環境では、自動的に認証が行われます。
この場合、環境変数の設定は不要です。

## 優先順位

認証情報の優先順位は以下の通りです：

1. `GOOGLE_APPLICATION_CREDENTIALS`環境変数（ファイルパス）
2. gcloud auth application-default loginで設定されたデフォルト認証
3. Google Cloud環境での自動認証（Cloud Run、GKEなど）

## 必要な権限

サービスアカウントには以下の権限が必要です：

- AI Platform Developer
- または以下のより具体的な権限：
  - `aiplatform.endpoints.predict`

## 動作確認

```bash
# 認証情報の確認
rails smart_search:test_embedding["テストテキスト"]

# 統計情報の確認
rails smart_search:stats
```

## トラブルシューティング

### 認証エラーが発生する場合

1. 環境変数が正しく設定されているか確認
2. サービスアカウントキーが有効か確認
3. プロジェクトIDが正しいか確認
4. 必要なAPIが有効化されているか確認

```bash
# Google Cloud CLIでAPIの有効化
gcloud services enable aiplatform.googleapis.com
```

### Base64エンコードが正しくない場合

```bash
# macOS/Linux
base64 -i service-account.json

# Windows
certutil -encode service-account.json encoded.txt
```

## セキュリティ注意事項

- サービスアカウントキーは機密情報として扱ってください
- Gitリポジトリにキー情報をコミットしないでください
- `.env`ファイルを使用する場合は`.gitignore`に追加してください
- 環境変数での管理を推奨します
- Base64エンコード方式を使用することで、ファイル管理のリスクを避けられます