# Codex Issue Automation

Issue に `Codex` ラベルを付けると、`work.comagata.org` を運用しているVPS上の
Codex CLIがGPT-5.6 SOLで実装し、ドラフトではない通常のPull Requestを作成
します。次回の定期実行では別のCodexセッションがレビューし、その後はCIと
CodeRabbitの結果を確認して最大3回まで修正します。自動mergeは行いません。
自動作成したopenなPRでは、監視完了後も、repositoryへの書き込み権限を持つ
ユーザーがconversation commentに `@codex` と書くと、次回の定期実行で回答し、
依頼に変更が必要なら同じPRへ修正をpushします。

OpenAIやAnthropicのAPIはGitHub Actionsから呼び出しません。Codex CLIは
ChatGPTアカウントで認証し、契約プランのCodex利用枠を使用します。

## VPSへの導入

WorkアプリのKamalコンテナとは分離し、VPSホスト上の専用ユーザーからDockerで
実行します。ホストへ導入するのはGit、Docker、`flock`だけです。Codex CLI、
GitHub CLI、Ruby、Node.js、PostgreSQL、Chrome等は専用コンテナ内で使用します。
以下は専用ユーザーのhomeを `/home/codex-bootcamp` とする例です。

1. VPSにGit、Docker、`flock`を導入し、専用ユーザーがDockerを実行できるように
   します。
2. 専用ユーザーでリポジトリを配置し、イメージをbuildします。

   ```sh
   git clone https://github.com/fjordllc/bootcamp.git \
     /home/codex-bootcamp/bootcamp
   cd /home/codex-bootcamp/bootcamp
   docker build \
     --file .github/codex/Dockerfile \
     --tag bootcamp-codex-automation .
   ```

3. コンテナ内のCodex CLIをChatGPTで認証し、GitHub CLIへログインします。

   ```sh
   bin/codex-issue-automation-docker login-codex
   bin/codex-issue-automation-docker login-github
   ```

   内部では `codex login --device-auth` と `gh auth setup-git` を使用します。
   GitHub認証には `fjordllc/bootcamp` のIssue、Pull Request、Contents、
   Actionsを読み書きできるfine-grained tokenまたはGitHub Appを使用します。

4. `crontab -e` に次を追加します。

   ```cron
   */5 * * * * cd /home/codex-bootcamp/bootcamp && git pull --ff-only origin main && bin/codex-issue-automation-docker >> /home/codex-bootcamp/codex-issue-automation.log 2>&1
   ```

認証情報は専用ユーザーだけが読める
`/home/codex-bootcamp/config/` に永続化します。パスワードと同様に扱い、Work
アプリのコンテナ、リポジトリ、ログへコピーしません。

Codexコンテナは非rootで実行し、リポジトリをread-onlyでmountします。Docker
socketは渡しません。テスト用PostgreSQLは実行ごとに別コンテナとして作成し、
終了時にnetworkとともに削除します。

## 実行方法

手動で一度だけ実行する場合は次のコマンドを使います。

```sh
bin/codex-issue-automation-docker
```

ランナーは `flock` で多重起動を防ぎます。対象Issue、管理対象PR、または
自動作成PRの未処理 `@codex` コメントがなければCodexを起動せず終了します。
各Codexセッションは一つの状態遷移だけを行うため、実装したセッションと
レビューするセッションは分離されます。

以下の環境変数で配置だけを変更できます。

- `CODEX_AUTOMATION_REPOSITORY`: 対象repository。既定値は
  `fjordllc/bootcamp`
- `CODEX_AUTOMATION_HOME`: 認証・作業directory。既定値は
  `/home/codex-bootcamp`
- `CODEX_AUTOMATION_IMAGE`: 使用するDocker image。既定値は
  `bootcamp-codex-automation`

## 停止条件

CIとCodeRabbitが成功し、別セッションのCodexレビューが完了し、未解決の有効な
review threadがなくなると、PRから `Codex` ラベルを外して監視を終了します。
自動修正が3回に達した場合もラベルを外し、人による確認を依頼します。
