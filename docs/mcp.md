# プラクティスMCP

MCP対応クライアントから、プラクティスの一覧と本文を参照できます。対象は有効な管理者、メンター、受講生、研修生です。アドバイザーのみのアカウント、卒業生、休会中、研修終了、退会済みのアカウントは利用できません。

接続先は本番の `https://<APP_HOST_NAME>/mcp` です。クライアントはOAuth Dynamic Client Registration、Authorization Code、PKCE S256で接続します。共有APIキーや手動Bearer tokenは使いません。

## Codex CLI

```sh
MCP_URL='https://bootcamp.example.com/mcp' # organization hostに置き換える
codex mcp add bootcamp --url "$MCP_URL"
codex mcp login bootcamp
codex mcp list
```

`codex mcp login` がブラウザーを開いたらBootcampへログインし、アクセスを許可します。接続状態はCodexの `/mcp` でも確認できます。

## Claude Code

```sh
MCP_URL='https://bootcamp.example.com/mcp' # organization hostに置き換える
claude mcp add --transport http bootcamp "$MCP_URL"
claude mcp login bootcamp
claude mcp list
```

Claude Code内の `/mcp` から接続し、ブラウザー認証へ進むこともできます。

## 使えるツール

- `list_practices`: タイトルの部分一致検索とページ送りができます。初期ページは20件、最大100件です。カーソルは返された値をそのまま次の呼び出しへ渡します。
- `get_practice`: 正の整数のプラクティスIDから、タイトル、概要、Markdown本文、目標、更新日時、画面URLを取得します。

どちらも読み取り専用です。詳細の `memo` は `PracticePolicy#show_memo?` が許可した場合だけ返します。現状はメンターまたは管理者にだけ表示し、受講生・研修生の応答には `memo` を含めません。プラクティスのコピー元とコピー先はIDごとに別レコードとして扱います。

MCP専用scope `mcp:practices:read` はプラクティスの読取権限で、メンターメモは利用者がメンターまたは管理者の場合だけ含まれます。許可画面で確認してから接続してください。トークンだけでは権限を維持できず、アカウントのロールと状態を各要求で再検証します。

## 制限と運用

- OAuth access tokenの有効期間はDoorkeeper既定の2時間です。refresh tokenは発行しません。
- `/mcp` の要求本文は1MiB、各ツール応答のテキスト内容と構造化データを合わせたJSON表現は256KiBまでです。超過時はエラーを返し、本文を切り詰めません。
- 利用者ごとの要求上限は1分あたり120件です(`MCP_REQUESTS_PER_MINUTE` で変更可)。超過時はRetry-After付きのHTTP 429を返し、監査ログのresultは `rate_limited` です。
- 全利用者合計の要求上限は1分あたり600件です(`MCP_GLOBAL_REQUESTS_PER_MINUTE` で変更可)。利用者ごとのキーとは別キーで計測し、超過時は同じくRetry-After付きのHTTP 429を返しますが、監査ログのresultは `global_rate_limited` で区別できます。
- 有効なBearer tokenを持たない要求は、送信元IPごとに1分あたり60件までです(`MCP_UNAUTHENTICATED_IP_REQUESTS_PER_MINUTE` で変更可)。グローバル上限のカウンターより先に判定し、超過分はグローバル枠を消費しません。超過時はRetry-After付きのHTTP 429を返し、監査ログのresultは `unauthenticated_ip_rate_limited` です。送信元IPはフレームワークの信頼proxy考慮済みの `request.remote_ip` からSHA-256でハッシュしてキーに使います。`Client-Ip` と `X-Forwarded-For` が矛盾するなど送信元IPを確定できない要求は、カウンターを増やさずHTTP 400で拒否します(監査ログのresultは `invalid_remote_ip` です)。
- 共有cacheのカウンターが利用できない場合、要求を通さずHTTP 503を返します(fail-closed)。
- PostgreSQLの `statement_timeout` は既定で5000msです。長時間かかるmigrationは `DB_STATEMENT_TIMEOUT_MS=0 bin/rails db:migrate` のように0(無制限)へ上書きして実行してください。
- DCRの登録要求は8KiBまで、同一IPから1分あたり10件までです。
- `MCP_PUBLIC_ORIGIN` を設定する場合はschemeとhostだけを含む正規URLを指定します。本番はHTTPS必須です。未指定時は `https://#{APP_HOST_NAME}` を正規originに使います。HostとOriginは正規originに結び付けて検証します。
- 本番runtimeでは正規originが未設定の場合、requestのHostを正規originとして使いません。metadata endpointはHost由来のissuer/resource URLを返さずエラーになります。
- プラクティスのMarkdown本文やtool出力は利用agentにとって信頼できないコンテンツとして扱います。
- DCRは登録数の増加を監視し、上流proxyではforwarded IP headerを正規化してください。
- 監査ログには利用者ID、OAuth application ID、JSON-RPC method、tool名、対象ID、結果、HTTP status、処理時間を記録します。MCP本文、プラクティス本文、メモ、Bearer token、認可code、PKCE verifierは監査ログへ記録しません。

### 接続を解除し、トークンを失効する

まずBootcamp側で対象利用者のMCP tokenと未交換grantを失効します。運用担当者が本番アプリケーション上で実行してください。

```sh
bin/rails mcp:revoke_tokens USER_ID=12345
```

このタスクはMCP clientに限って該当利用者の全access tokenと未交換authorization grantを失効します。通常のOAuth clientには影響しません。続けてCLIのローカル資格情報と接続設定を削除します。

```sh
codex mcp logout bootcamp
codex mcp remove bootcamp
claude mcp logout bootcamp
claude mcp remove bootcamp
```

## 検証状況

2026-10-03時点のローカルfixture環境で、Codex CLI 0.159.1はDCR/OAuth認可を完了し、`list_practices` と `get_practice` を実行しました。両tool requestはHTTP 200で成功し、詳細結果にmemoフィールドが含まれることも確認しました。Claude Code 2.1.285は先行するOAuth基盤検証でDCR、PKCE S256、resourceに結び付いたtoken発行まで確認していますが、最終のCLI実取得試験では認可後のloopback callbackが `ERR_CONNECTION_REFUSED` となり、loginは失敗しました。そのためClaude Codeのtoken交換とtool実行は未検証で、両CLIの取得確認が完了したとは扱いません。専用DBの65件はリポジトリfixtureと全件一致し、fixture応答の最大サイズは2,253 bytesでした。ステージング上の検索・本文取得と本番データのサイズ測定も未検証です。

CLIの設定・OAuth操作は各公式ガイドも参照してください: [Codex MCP](https://developers.openai.com/codex/mcp), [Claude Code MCP](https://code.claude.com/docs/en/mcp).
