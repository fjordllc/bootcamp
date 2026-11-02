# ステージングでのリリース検証用フィクスチャ

`db/fixtures/users.yml` にある既存のステージングアカウントを、リポジトリのフィクスチャ用パスワード `testtest` で使用します。対象は `komagata`（管理者）、`mentormentaro`（メンター）、`kimura`（受講生）、`advijirou`（アドバイザー）、`kensyu`（研修生）です。退会済みまたは非アクティブなロールの例には `kensyuowata` と `yameo` があります。これらのアカウントでログインできるかどうかは、現在のアプリケーションの状態によります。

## AIレビュー支援カード

`products.yml` のラベル `product13`（`OS X Mountain Lionをクリーンインストールする`）に対応する提出物を開き、`mentormentaro` または `komagata` でログインします。提出物の本文の後にカードが表示されることを確認します。`kimura` または `advijirou` では、カードとその内容が表示されないことを確認します。`fictional_sample_for_product13` のレビューは静的な表示用データであり、AIが生成したレビューではありません。`example.invalid` のリンクは説明用の例です。Docs、URL、GitHub、その他の外部ソースを取得したことや、モデルのコンテキストに含めたことを示すものではありません。

## その他のリリースPRのスモークチェック

既存のフィクスチャには、`pages.yml` の `page1` と公開済みのDocsページ、`questions.yml` の `question1`、`talks.yml` の `talk_komagata`、`bookmarks.yml` の `product1` に対する `bookmark29`、`checks.yml` の `product2_check_komagata` などの確認データがあります。該当するロールでログインして、対応するUIや `config/routes/api.rb` のAPIパスを確認します。これらはサンプルレコードであり、存在するだけでは外部連携の結果を確認したことにはなりません。OAuthやAnthropicのサービスを呼び出す検証では、OAuthのread/writeトークンとAnthropic APIキーをステージング環境で設定する必要があります。これらは公開フィクスチャには保存されていません。
