# Codex Issue Automation

Issue に `Codex` ラベルを付けると、`work.comagata.org` を運用しているVPS上の
Codex CLIがGPT-5.6 SOLで実装し、ドラフトではない通常のPull Requestを作成
します。次回の定期実行では別のCodexセッションがレビューし、その後はCIと
CodeRabbitの結果を確認して最大3回まで修正します。自動mergeは行いません。

OpenAIやAnthropicのAPIはGitHub Actionsから呼び出しません。Codex CLIは
ChatGPTアカウントで認証し、契約プランのCodex利用枠を使用します。

## VPSへの導入

WorkアプリのKamalコンテナとは分離し、VPSホスト上の専用ユーザーで実行します。
以下は専用ユーザーのhomeを `/home/codex-bootcamp` とする例です。

1. VPSにGit、GitHub CLI、Codex CLI、`flock`、およびbootcampの開発・テストに
   必要なRuby、Node.js、PostgreSQL、Chrome等を導入します。
2. 専用ユーザーでChatGPTとGitHubへログインします。

   ```sh
   codex login --device-auth
   gh auth login --hostname github.com --git-protocol https
   gh auth setup-git
   ```

   GitHub認証には `fjordllc/bootcamp` のIssue、Pull Request、Contents、
   Actionsを読み書きできるfine-grained tokenまたはGitHub Appを使用します。

3. 専用ユーザーでリポジトリを配置します。

   ```sh
   git clone https://github.com/fjordllc/bootcamp.git \
     /home/codex-bootcamp/bootcamp
   mkdir -p /home/codex-bootcamp/work
   ```

4. `crontab -e` に次を追加します。

   ```cron
   */5 * * * * cd /home/codex-bootcamp/bootcamp && git pull --ff-only origin main && CODEX_AUTOMATION_WORKSPACE=/home/codex-bootcamp/work bin/codex-issue-automation >> /home/codex-bootcamp/codex-issue-automation.log 2>&1
   ```

定期実行前に `codex login status` と `gh auth status` が成功することを確認します。
認証キャッシュはパスワードと同様に扱い、Workアプリのコンテナ、リポジトリ、
ログへコピーしません。

## 実行方法

手動で一度だけ実行する場合は次のコマンドを使います。

```sh
CODEX_AUTOMATION_WORKSPACE=/home/codex-bootcamp/work \
  bin/codex-issue-automation
```

ランナーは `flock` で多重起動を防ぎます。対象Issueまたは管理対象PRがなければ
Codexを起動せず終了します。各Codexセッションは一つの状態遷移だけを行うため、
実装したセッションとレビューするセッションは分離されます。

以下の環境変数で配置だけを変更できます。

- `CODEX_AUTOMATION_REPOSITORY`: 対象repository。既定値は
  `fjordllc/bootcamp`
- `CODEX_AUTOMATION_WORKSPACE`: 一時cloneの親directory。既定値は
  `/var/lib/codex-bootcamp`
- `CODEX_AUTOMATION_LOCK_FILE`: 排他lock。既定値は
  `/tmp/codex-bootcamp.lock`

## 停止条件

CIとCodeRabbitが成功し、別セッションのCodexレビューが完了し、未解決の有効な
review threadがなくなると、PRから `Codex` ラベルを外して監視を終了します。
自動修正が3回に達した場合もラベルを外し、人による確認を依頼します。
