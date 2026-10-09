# 理解度テスト API

`/api/practices/:practice_id/practice_quiz` は JSON の GET / POST / PATCH / PUT / DELETE に対応します。
`Authorization: Bearer <OAuthアクセストークン>` を指定してください。
GET は `mentor`、POST / PATCH / PUT / DELETE は `mentor` と `write` の両スコープが必要です。
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

## PATCH / PUT

既存クイズの公開状態・問題・選択肢を更新します。両メソッドとも、指定しなかった属性や問題・選択肢は保持します。
`practice_quiz.published` を `true` / `false` にすると公開・非公開を切り替えます。
問題の `id` はこのクイズの問題、選択肢の `id` はその問題の選択肢を指定してください。
`id` を省略すると追加、`id` と `_destroy: true` を指定すると削除します。
新しい問題の `published` は省略時に `true` です。
ネストした属性は配列、`published` / `correct` / `_destroy` はJSONの真偽値で指定してください。
空の選択肢は無視せずエラーにします。

更新後に残る問題は、未公開でもPOSTと同じ完全な選択肢の検証を行います。
公開クイズには公開中の問題が1つ以上必要です。最後の公開問題も、同じリクエストで別の公開問題を追加することで置き換えられます。
回答で参照されている選択肢や、その選択肢を含む問題は削除できません。
受験履歴と回答は編集時に保持します。検証エラーや不正なIDがあれば、公開状態を含むすべての変更を取り消します。

リクエスト例（`PATCH /api/practices/456/practice_quiz`、`Content-Type: application/json`）:

```json
{
  "practice_quiz": {
    "published": true,
    "practice_quiz_questions_attributes": [
      {
        "id": 789,
        "body": "更新した問題文です。",
        "practice_quiz_choices_attributes": [
          { "id": 101, "body": "更新した正解" },
          { "id": 102, "_destroy": true },
          { "body": "新しい不正解", "correct": false, "position": 2 }
        ]
      }
    ]
  }
}
```

PUTも同じURL・JSON形式で送信できます。公開状態だけを更新する例:

```json
{ "practice_quiz": { "published": false } }
```

成功時は **200 OK** で、GETと同じ形式を返します。

## DELETE

`DELETE /api/practices/:practice_id/practice_quiz` を送信します。リクエスト本文は不要です。
受験履歴がないクイズを、問題・選択肢とともに削除します。公開中のクイズも削除できます。
成功時は **204 No Content** で本文は空です。その後のGETは404になります。
受験履歴がある場合は **409 Conflict** で拒否し、クイズ・問題・選択肢・受験履歴・回答をすべて保持します。
削除時のコールバックが拒否した場合は422を返し、すべての変更を取り消します。

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
| 404 | プラクティスなし、またはGET / PATCH / PUT / DELETE時にクイズなし、更新時の問題・選択肢IDが対象に属さないか存在しない |
| 409 | POST時にクイズが既に存在する、またはDELETE時に受験履歴がある（既存データは変更しません） |
| 422 | POST / PATCH / PUTの問題・選択肢・入力形式が不正、または削除がモデルの制約で拒否された |

422は `{"errors": {"属性名": ["検証メッセージ"]}}` の形式で返します。
404 / 409は `{"message": "説明"}` を返します。
スコープ不足は既存OAuth APIと同じ `invalid_scope` エラーです。
