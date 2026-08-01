# AI Issue Automation

Issue に `AI` ラベルを付けると、GPT-5.6 SOL（Codex）が実装して通常の
Pull Request を作成します。作成後は Claude がレビューし、既存の
CodeRabbit と CI の結果を5分ごとに確認します。
失敗や未解決の指摘があれば Codex が最大3回まで修正します。自動mergeは
行いません。

## 必要なGitHub Actions secrets

- `OPENAI_API_KEY`: `openai/codex-action` が使用するOpenAI API key
- `ANTHROPIC_API_KEY`: Claudeによるレビューに使用するAPI key
- `CODEX_GITHUB_TOKEN`: branchのpush、通常PRの作成、コメント、ラベル操作に
  使用するfine-grained personal access tokenまたはGitHub App token

`CODEX_GITHUB_TOKEN` には、このrepositoryに対する Contents、Issues、
Pull requests の read/write 権限が必要です。`GITHUB_TOKEN` で作成したPRが
後続のGitHub Actionsを起動しない制約を避けるため、別tokenを使用します。

## 停止条件

CIが成功し、ClaudeとCodeRabbitのレビューが完了し、両者の未解決
review threadがなくなると、PRから`AI`ラベルを外して監視を終了します。
自動修正が3回に達した場合もラベルを外し、人による確認を依頼します。
