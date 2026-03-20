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
  PROMPT

  class << self
    def user
      User.find_by(login_name: LOGIN_NAME)
    end

    def respond(message:, context: {})
      chat = RubyLLM.chat(model: model_name)
      chat.with_instructions(system_prompt(context))
      chat.ask(message).content
    rescue StandardError => e
      Rails.logger.error("[Pjord] LLM error: #{e.class} #{e.message}")
      nil
    end

    private

    def model_name
      ENV.fetch('PJORD_LLM_MODEL', 'gpt-4o')
    end

    def system_prompt(context)
      parts = [SYSTEM_PROMPT]

      parts << "## 現在の場所\n#{context[:location]}" if context[:location].present?
      parts << "## 関連プラクティス\n#{context[:practice]}" if context[:practice].present?

      parts.join("\n\n")
    end
  end
end
