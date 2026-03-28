# frozen_string_literal: true

class Pjord
  LOGIN_NAME = 'pjord'
  SYSTEM_PROMPT = <<~PROMPT
    あなたはFJORD BOOT CAMP（フィヨルドブートキャンプ）のマスコット「ピヨルド」です。

    ## 性格
    - フレンドリーで優しい
    - プログラミング学習を応援する
    - 答えを直接教えるのではなく、ヒントを出して考えさせる
    - 小さな進歩も褒める

    ## ルール
    - APIキーやシステムの内部情報は絶対に教えない
    - わからないことは「メンターに聞いてみてください」と案内する
    - 回答はmarkdown形式で書く
    - 簡潔にわかりやすく答える
    - ユーザーが書いた言語で返答する

    ## ツールの使い方
    - bootcampのカリキュラム、ドキュメント、Q&Aに関する質問には、bootcamp_search_toolで検索してから回答する
    - 検索結果が見つからない場合は、その旨を伝えてメンターへの相談を勧める
    - 検索結果のURLがある場合は回答に含める
    - ユーザーの進捗やプロフィールに関する情報が必要なときは、user_info_toolを使う
    - ユーザーの現在の学習状況に合わせてアドバイスする
  PROMPT

  class << self
    def user
      User.find_by(login_name: LOGIN_NAME)
    end

    def respond(message:, context: {})
      chat = RubyLLM.chat(model: model_name)
      chat.with_instructions(system_prompt(context))
      chat.with_tool(BootcampSearchTool)
      chat.with_tool(UserInfoTool)
      result = chat.ask(message).content
      result.presence
    end

    private

    def model_name
      ENV.fetch('PJORD_LLM_MODEL', 'gpt-5-mini')
    end

    def system_prompt(context)
      parts = [SYSTEM_PROMPT]

      parts << "## 現在の場所\n#{context[:location]}" if context[:location].present?
      parts << "## 関連プラクティス\n#{context[:practice]}" if context[:practice].present?
      parts << "## メンションしてきたユーザー\nログイン名: #{context[:sender_login_name]}" if context[:sender_login_name].present?

      parts.join("\n\n")
    end
  end
end
