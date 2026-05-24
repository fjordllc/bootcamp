# Cloud Run service YAML

Cloud Run の実行時設定は環境別の service YAML で管理する。

- `production.yaml`: 本番環境
- `staging.yaml`: ステージング環境

Cloud Build は deploy 時に image URL、Cloud SQL instance、host name などの非 secret 値だけを
`bin/render-cloud-run-service` で placeholder に埋め込み、`gcloud run services replace` で Cloud Run に反映する。

Secret の実値は Cloud Build substitutions ではなく Secret Manager に保存し、service YAML から
Secret Manager の secret version を参照する。

## Secret Manager の命名規則

Cloud Run service YAML は以下の命名規則で Secret Manager を参照する。

```text
bootcamp-<environment>-<secret-name>
```

例:

```text
bootcamp-production-rails-master-key
bootcamp-production-db-pass
bootcamp-staging-rails-master-key
bootcamp-staging-db-pass
```

Cloud Build 内で DB migration や deploy notification に必要な secret も、各 Cloud Build
設定ファイルの `availableSecrets` から同じ命名規則の secret を読む。

## 反映前の確認

新しい secret を追加した場合は、Cloud Run の実行サービスアカウントと Cloud Build の
サービスアカウントに必要な Secret Manager Secret Accessor 権限が付いていることを確認する。

既存の Cloud Build trigger substitutions から Secret Manager に初期移行する場合は、以下を実行する。

```bash
bin/migrate-cloud-run-secrets
```

このコマンドは secret の値を標準出力に表示しない。既に存在する secret は更新せず、
存在しない secret だけを作成する。

作成対象だけを確認する場合は dry-run で実行する。

```bash
DRY_RUN=1 bin/migrate-cloud-run-secrets
```
