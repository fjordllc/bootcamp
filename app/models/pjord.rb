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
    - 語尾に「ピヨ」など特徴的な語尾は付けず、通常の丁寧な日本語で話す
    - 検索結果を踏まえたこと、ツールを使ったこと、コメントや回答を作成することなど、内部の手順説明は出力しない

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

    def respond(message:, context: {}, instructions: nil)
      chat = RubyLLM.chat(model: model_name)
      chat.with_instructions(system_prompt(context, instructions:))
      chat.with_tool(BootcampSearchTool)
      chat.with_tool(UserInfoTool)
      chat.with_schema(PjordResponse)
      result = extract_public_response_body(chat.ask(message).content)
      result.presence
    end

    def classify_report(title:, description:)
      chat = RubyLLM.chat(model: model_name)
      chat.with_instructions(classify_instructions)
      chat.with_schema(PjordReportIntent)
      content = chat.ask(classify_message(title:, description:)).content
      parsed =
        if content.is_a?(String)
          JSON.parse(content)
        elsif content.respond_to?(:to_h)
          content.to_h
        else
          content
        end
      return nil unless parsed.is_a?(Hash)

      parsed = parsed.stringify_keys
      intent = parsed['intent']
      return nil unless PjordReportIntent::INTENTS.include?(intent)

      { intent: intent, reason: parsed['reason'] }
    rescue JSON::ParserError => e
      Rails.logger.error("[Pjord.classify_report] JSON parse error: #{e.message}")
      nil
    end

    private

    def classify_instructions
      <<~TEXT
        あなたは日報の内容を分類する分類器です。
        与えられた日報を読み、指定されたスキーマに従って `intent` を1つだけ選んでください。
        余計な文章は一切出力せず、スキーマで定義された構造化データのみを返してください。
      TEXT
    end

    def classify_message(title:, description:)
      <<~TEXT
        以下の日報を分類してください。

        ## タイトル
        #{title}

        ## 本文
        #{description}
      TEXT
    end

    def model_name
      ENV.fetch('PJORD_LLM_MODEL', 'claude-sonnet-4-6')
    end

    def system_prompt(context, instructions: nil)
      parts = [SYSTEM_PROMPT]

      parts << "## 追加の指示\n#{instructions}" if instructions.present?
      parts << "## 現在の場所\n#{context[:location]}" if context[:location].present?
      parts << "## 関連プラクティス\n#{context[:practice]}" if context[:practice].present?
      parts << "## メンションしてきたユーザー\nログイン名: #{context[:sender_login_name]}" if context[:sender_login_name].present?

      parts.join("\n\n")
    end

    def extract_public_response_body(content)
      body =
        if content.is_a?(String)
          parse_response_body(content)
        elsif content.respond_to?(:to_h)
          content.to_h['body'] || content.to_h[:body]
        end

      remove_internal_preamble(body)
    end

    def parse_response_body(content)
      JSON.parse(content)['body']
    rescue JSON::ParserError
      content
    end

    def remove_internal_preamble(body)
      return body unless body.is_a?(String)

      body.sub(/\A\s*(?:検索結果を踏まえて、)?(?:日報へのコメント|回答|コメント)を作成します。\s*/, '')
    end
  end
end
