# Railsのエラー処理

[エラー処理と通知](error_handling.md)の判断基準を、Railsのリクエスト処理に当てはめます。

## 迷ったときの表

| 状況 | Railsでの扱い |
| --- | --- |
| 入力検証で保存できない | `save`が`false`なら`render :new, status: :unprocessable_entity`（422）。入力値と`errors`を画面に戻す |
| 対象レコードがない | `find`の通常の404処理に任せる。通常の404をエラー通知にしない |
| 権限・認可で拒否した | 通常の拒否として応答する。botの設定不備と混同しない |
| 想定外の例外 | 通常は捕捉せず伝播させ、自動報告に任せる |

## createアクションの例

以下は説明用の例です。article_paramsはアプリ側で定義し、フォームに必要な選択肢なども準備してください。

```ruby
def create
  @article = Article.new(article_params)

  if @article.save
    redirect_to @article
  else
    # 再描画するviewに必要なデータがあれば、ここで準備する
    render :new, status: :unprocessable_entity
  end
end
```

`new.html.erb`ではモデルのエラーを表示します。

```erb
<% if @article.errors.any? %>
  <ul>
    <% @article.errors.full_messages.each do |message| %>
      <li><%= message %></li>
    <% end %>
  </ul>
<% end %>
```

`render`は同じリクエスト内の`@article`を使うため、入力値と`errors`を表示できます。再描画に必要な選択肢などのview用データも、`render`前に準備します。詳しくはRailsガイドの[バリデーション](https://guides.rubyonrails.org/active_record_validations.html)と[例外処理・rescue_from](https://guides.rubyonrails.org/action_controller_advanced_topics.html#rescue-from)を参照してください。

## 捕捉するなら狭くする

`rescue_from StandardError`で広く捕捉したり、`rescue nil`で失敗を隠したりしないでください。回復・応答を決められる具体的な例外だけを捕捉します。例外を捕捉して再送出しない場合、自動報告には届かないため、必要な報告を明示してください。伝播する例外を手動で重ねて報告する必要はありません。

Rollbarの文脈には`request_id`を使い、トークンや秘密情報を含めません。独自のログに秘密情報を書かないでください。追加データも送信前に確認します。`Rails.logger.warn`はログ出力であり、`Rollbar.warning`によるトラッカー報告とは別です。

一時的な再試行など、個別通知は不要でも後から頻度を調べたい失敗は、収集・閾値設定をしたログへ記録できます。次は例であり、現在の実装を示すものではありません。

```ruby
Rails.logger.warn({event: "external_api_retry", request_id: request.request_id}.to_json)
```

loggerに書くだけではアラートになりません。ログの収集先と閾値アラートを別途設定してください。`config.filter_parameters`は手作業で組み立てた`Rails.logger`の文字列やJSONを自動で伏せません。Rollbarのデータフィルタリングも別の仕組みなので、各送信先に秘密情報を含めないよう個別に確認します。

Rails向けRollbar SDKは未捕捉例外を自動報告し、手動捕捉した例外やメッセージは`Rollbar.error`等で報告できます。404の既定warningフィルターなどSDKの振る舞いは、設定やバージョンを確認してください。現在の設定が特定の404を除外しているとは決めつけず、[Rollbar Ruby SDKの説明](https://docs.rollbar.com/docs/ruby)を参照します。

Discordチャンネル削除だけは、退会を完了させるための限定例外です。適用条件と復旧手順は[エラー処理と通知](error_handling.md#bootcampの限定的な業務例外-discordチャンネル削除)を確認してください。
