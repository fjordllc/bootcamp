# チーム向けGoogle Cloud認証設定ガイド

## 🎯 目標
Google CloudのサービスアカウントJSONファイルを安全に管理・共有する

## 🔧 設定フロー

### 1. サービスアカウント管理者（初回のみ）

#### Google Cloud サービスアカウントのJSON取得
1. Google Cloud Consoleでサービスアカウントキーを作成
2. JSONファイルをダウンロード（例: `service-account-key.json`）

#### チームに共有
- Slack のプライベートチャンネル（ファイル共有）
- 社内ドキュメント（セキュアな場所）
- パスワード管理ツール
- Google Drive（アクセス制限付き）

**共有する情報:**
- サービスアカウントのJSONファイル
- プロジェクトID: `your-project-id`

### 2. チームメンバー

#### 方法A: .envファイル作成（推奨）
```bash
# JSONファイルを適切な場所に配置
mkdir -p ~/secrets
cp ~/Downloads/service-account-key.json ~/secrets/

# .envファイルを作成
cat > .env << 'EOF'
# Google Cloud認証
GOOGLE_APPLICATION_CREDENTIALS=/Users/your-username/secrets/service-account-key.json
GOOGLE_CLOUD_PROJECT=your-project-id
EOF

# .envファイルを.gitignoreに追加（まだの場合）
echo ".env" >> .gitignore
# JSONファイルも.gitignoreに追加
echo "*.json" >> .gitignore
```

#### 方法B: 環境変数に直接設定
```bash
# 環境変数を設定
export GOOGLE_APPLICATION_CREDENTIALS="/path/to/service-account-key.json"
export GOOGLE_CLOUD_PROJECT="your-project-id"
```

## 🚀 動作確認

```bash
# 環境変数が設定されているか確認
echo $GOOGLE_APPLICATION_CREDENTIALS
echo $GOOGLE_CLOUD_PROJECT

# JSONファイルが存在するか確認
ls -la $GOOGLE_APPLICATION_CREDENTIALS

# アプリケーションで動作確認
rails smart_search:test_embedding["テストテキスト"]
```

## 💡 メリット

- ✅ **標準的な方法**: Google Cloud SDKの標準的な認証方法
- ✅ **Git安全**: 認証情報がリポジトリに入るリスクなし（.gitignore使用）
- ✅ **デバッグ簡単**: ファイルパスが明確で問題の特定が容易
- ✅ **互換性高**: 他のGoogle Cloudツールとの互換性が高い

## 🔒 セキュリティ注意事項

1. **JSONファイルの管理**
   - プロジェクトディレクトリ外に保存を推奨（例: `~/secrets/`）
   - 必ず.gitignoreに`*.json`を追加
   - ファイルのパーミッションを適切に設定（`chmod 600`）

2. **ローカル環境**
   - .envファイルは必ず.gitignoreに追加
   - 作業完了後は不要なファイル削除を推奨

3. **本番環境**
   - Cloud Run: Secret Managerを使用
   - Heroku: Config Varsを使用
   - AWS: Systems Manager Parameter Store
   - その他: 各プラットフォームの推奨方法

## 🛠️ トラブルシューティング

### ファイルが見つからないエラー
```bash
# ファイルパスが正しいか確認
ls -la $GOOGLE_APPLICATION_CREDENTIALS

# 絶対パスを使用しているか確認
realpath ~/secrets/service-account-key.json
```

### 権限エラー
```bash
# ファイルの権限を確認・修正
chmod 600 ~/secrets/service-account-key.json
```

## 📋 チェックリスト

### 管理者
- [ ] サービスアカウントJSONファイルを作成
- [ ] チームにセキュアに共有
- [ ] プロジェクトIDも合わせて共有

### メンバー
- [ ] JSONファイルを安全な場所に保存
- [ ] 環境変数にファイルパスを設定
- [ ] .envファイルを.gitignoreに追加
- [ ] 動作確認テストを実行