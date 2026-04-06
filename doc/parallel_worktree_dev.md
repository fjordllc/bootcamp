# git worktree並列開発 (Linux + Docker)

複数機能を git worktree で並列開発するための、Linux用Docker環境です。
macOS版(`doc/development_on_docker.md`)やホストPostgreSQL直接利用とは別系統の、独立したセットアップです。

## 前提

- Docker Engine + docker compose (v2以降)
- git worktree
- Linux (Arch/Ubuntu等)

## 関連ファイル

- `Dockerfile.dev` - dev用軽量イメージ (Ruby 3.4.3 + Node 22)
- `docker-compose.yml` - web + db サービス定義

## 並列運用の仕組み

1. 各worktreeは**独立したcompose stack** (`COMPOSE_PROJECT_NAME` を `.env.local` で一意化)
2. **DB/bundle/node_modules** はworktreeごとに別ボリューム
3. **WEB_PORT** は worktree ごとに別 (`.env.local` で設定、3010-3099)
4. DBコンテナもworktreeごとに独立 → **DB名の衝突なし** (BRANCH_DB_SUFFIX不要)

## 手順

### 1. worktreeを作成

```bash
cd ~/Works/fjordllc/bootcamp
git worktree add .claude/worktrees/qa -b qa
cd .claude/worktrees/qa
```

### 2. .env.local を生成

各worktreeは**独立したDBコンテナ**を持つのでDB名は標準の `bootcamp_development` でOK。
worktree間で衝突するのは**ホストポート**と`COMPOSE_PROJECT_NAME`だけ。

```bash
cat > .env.local <<EOF
WEB_PORT=3010
COMPOSE_PROJECT_NAME=bootcamp_qa
EOF
```

※ `claude-launcher` 経由で worktree を作れば自動生成される (空きポート自動割当)。

### 3. 起動

```bash
docker compose --env-file .env.local up -d --build
```

初回は bundle/npm インストール + db:prepare が走るので数分かかる (webコンテナのCMDが自動実行)。

`http://localhost:3010` をブラウザで開く。

### 4. 停止

```bash
docker compose --env-file .env.local down
docker compose --env-file .env.local down -v  # ボリュームも削除(DB初期化)
```

## Rails コマンドの実行

```bash
docker compose --env-file .env.local exec web bin/rails <cmd>
docker compose --env-file .env.local exec web bundle <cmd>
docker compose --env-file .env.local exec web bin/rails test
docker compose --env-file .env.local exec web bash      # シェルに入る
```

毎回 `--env-file .env.local` を付けるのが面倒なら、シェルエイリアスや direnv で対応:

```bash
# ~/.bashrc に追加
alias dc='docker compose --env-file .env.local'
# → dc exec web bin/rails c
```

## 注意事項

- **5並列まで**を目安に (メモリ消費が大きい)
- **初回ビルドは数分** (gem + npmインストール)
- `.env.local` は `.gitignore` 対象、コミットしない
- 不要になった worktree は `git worktree remove .claude/worktrees/<name>` + `docker compose --env-file .env.local down -v` で完全削除
