# 理解度テスト API

`/api/practices/:practice_id/practice_quiz` は JSON の GET / POST に対応します。
`Authorization: Bearer <OAuthアクセストークン>` を指定してください。
GET は `mentor`、POST は `mentor` と `write` の両スコープが必要です。
トークンの所有者は有効なメンターまたは管理者である必要があります。
ログインセッションや `/api/session` の JWT だけでは利用できません。
正解を含むため、受講生には公開しないAPIです。

## POST

既存のテストがないプラクティスに、問題・選択肢を一括保存します。
クイズ自体は必ず未公開です。クイズへの `published: true` は無視します。
問題の `published` は省略時に `true`、選択肢の `correct` は省略時に `false` です。
`question_type` は `single_choice` または `multiple_choice` を指定します。
問題は1つ以上、各問題の選択肢は2つ以上必要です。本文は空にできません。
単一選択には正解が1つ、複数選択には正解が1つ以上必要です。
問題が未公開でも同じ検証を行います。失敗時は一切保存しません。
`published` / `correct` を指定する場合は JSON の真偽値を使ってください。
IDを指定して既存の問題や選択肢を更新することはできません。

リクエスト例（`Content-Type: application/json`）:

```json
{
  "practice_quiz": {
    "practice_quiz_questions_attributes": [
      {
        "question_type": "single_choice",
        "body": "正しいものを選んでください。",
        "explanation": "解説です。",
        "position": 1,
        "published": true,
        "practice_quiz_choices_attributes": [
          { "body": "正解", "correct": true, "position": 1 },
          { "body": "不正解", "correct": false, "position": 2 }
        ]
      }
    ]
  }
}
```

成功時は **201 Created** で、GET と同じ形式を返します。

## GET

公開状態にかかわらず、問題・選択肢と正解を返します。
問題・選択肢はそれぞれ `position`、`id` の昇順です。
成功時は **200 OK** です。

レスポンス例（IDは保存時に採番されます）:

```json
{
  "id": 123,
  "practice_id": 456,
  "published": false,
  "questions": [
    {
      "id": 789,
      "question_type": "single_choice",
      "body": "正しいものを選んでください。",
      "explanation": "解説です。",
      "position": 1,
      "published": true,
      "choices": [
        { "id": 101, "body": "正解", "correct": true, "position": 1 },
        { "id": 102, "body": "不正解", "correct": false, "position": 2 }
      ]
    }
  ]
}
```

## エラー

| HTTP | 条件 |
| --- | --- |
| 401 | OAuthトークンなし・期限切れ・失効済み、または無効なユーザー |
| 403 | 必要なスコープなし、または所有者がメンター・管理者でない |
| 404 | プラクティスなし、またはGET時にクイズなし |
| 409 | POST時にクイズが既に存在する（既存データは変更しません） |
| 422 | POSTの問題・選択肢・入力形式が不正 |

422は `{"errors": {"属性名": ["検証メッセージ"]}}` の形式で返します。
404 / 409は `{"message": "説明"}` を返します。
スコープ不足は既存OAuth APIと同じ `invalid_scope` エラーです。
