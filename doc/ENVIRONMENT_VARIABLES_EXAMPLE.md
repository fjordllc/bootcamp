# 環境変数設定例

## Google Cloud認証設定

### Base64エンコード方式（推奨）

```bash
# 1. サービスアカウントのJSONファイルをBase64エンコード
cat service-account.json | base64 -w 0 > encoded-credentials.txt

# 2. 環境変数に設定
export GOOGLE_CLOUD_CREDENTIALS_BASE64="$(cat encoded-credentials.txt)"
export GOOGLE_CLOUD_PROJECT="your-project-id"
```

### .envファイルの例

```env
# Google Cloud設定（Base64エンコード方式）
GOOGLE_CLOUD_CREDENTIALS_BASE64=ewogICJ0eXBlIjogInNlcnZpY2VfYWNjb3VudCIs...
GOOGLE_CLOUD_PROJECT=your-project-id
```

### Docker Composeの例

```yaml
version: '3.8'
services:
  app:
    environment:
      - GOOGLE_CLOUD_CREDENTIALS_BASE64=${GOOGLE_CLOUD_CREDENTIALS_BASE64}
      - GOOGLE_CLOUD_PROJECT=${GOOGLE_CLOUD_PROJECT}
```

### Herokuの例

```bash
# Base64エンコードした認証情報を設定
heroku config:set GOOGLE_CLOUD_CREDENTIALS_BASE64="$(cat service-account.json | base64 -w 0)"
heroku config:set GOOGLE_CLOUD_PROJECT="your-project-id"
```

### Cloud Runの例

```bash
# Secret Managerに認証情報を保存
echo -n "$(cat service-account.json | base64 -w 0)" | gcloud secrets create google-credentials-base64 --data-file=-

# Cloud Runサービスにシークレットをマウント
gcloud run deploy your-service \
  --set-secrets="GOOGLE_CLOUD_CREDENTIALS_BASE64=google-credentials-base64:latest" \
  --set-env-vars="GOOGLE_CLOUD_PROJECT=your-project-id"
```

## 重要な注意事項

1. **macOSでのBase64エンコード**
   ```bash
   # macOSでは-wオプションが使えないため
   cat service-account.json | base64
   ```

2. **改行の扱い**
   - Base64エンコード時に改行が含まれる場合は、1行にまとめてください
   - 多くの環境では自動的に処理されますが、問題が発生する場合は手動で改行を除去してください

3. **セキュリティ**
   - 認証情報を含む.envファイルは必ず.gitignoreに追加してください
   - 本番環境では環境変数管理サービスやシークレット管理ツールの使用を推奨します