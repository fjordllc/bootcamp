# frozen_string_literal: true

class ProductAiReviewer
  MODEL = 'claude-opus-4-1-20250805'
  OTHER_PRODUCTS_LIMIT = 10
  PROMPT_TEXT_LIMIT = 2_000

  class << self
    def review(product)
      chat = RubyLLM.chat(model: MODEL)
      chat.with_instructions(instructions)
      chat.with_schema(PjordResponse)
      extract_public_response_body(chat.ask(message(product)).content).presence
    end

    private

    def instructions
      <<~TEXT
        あなたはFJORD BOOT CAMPのマスコット「ピヨルド」として、提出物にレビューコメントを書きます。
        受講生を励ましつつ、提出物の内容を具体的に確認し、改善点があれば短く実行可能な形で伝えてください。
        模範解答や他の提出物の内容をそのままコピーせず、答えを丸ごと教えないでください。
        レビューコメント本文だけをmarkdownで出力してください。
      TEXT
    end

    def message(product)
      user_course_practice = UserCoursePractice.new(product.user)
      <<~TEXT
        以下の情報を参考に、提出物へのレビューコメントを書いてください。

        ## 提出者
        - ログイン名: #{product.user.login_name}
        - 名前: #{product.user.name}
        - プロフィール: #{product.user.description.presence || '未入力'}
        - 進捗率: #{completed_percentage(user_course_practice)}

        ## プラクティス
        - タイトル: #{product.practice.title}
        - 説明:
        #{truncate_for_prompt(product.practice.description)}

        ## 提出物
        #{truncate_for_prompt(product.body)}

        ## 提出物内のGitHubリンク先コード
        #{github_code_links(product)}

        ## 同じ提出物に対するコメント
        #{comments(product)}

        ## 模範解答
        #{submission_answer(product)}

        ## 同じプラクティスの他の提出物
        #{other_products(product)}
      TEXT
    end

    def comments(product)
      return 'なし' if product.comments.blank?

      product.comments.includes(:user).order(:created_at).map do |comment|
        "- #{comment.user.login_name}: #{truncate_for_prompt(comment.description)}"
      end.join("\n")
    end

    def submission_answer(product)
      truncate_for_prompt(product.practice.submission_answer&.description).presence || 'なし'
    end

    def other_products(product)
      products = product.practice.products.not_wip.where.not(id: product.id).includes(:user).order(published_at: :desc, id: :desc).limit(OTHER_PRODUCTS_LIMIT)
      return 'なし' if products.blank?

      products.map do |other_product|
        "### #{other_product.user.login_name}さんの提出物\n#{truncate_for_prompt(other_product.body)}"
      end.join("\n\n")
    end

    def github_code_links(product)
      entries = ProductAiReviewer::GithubCodeFetcher.fetch(product.body)
      return 'なし' if entries.blank?

      entries.map do |entry|
        <<~TEXT
          ### #{entry[:url]}
          ```#{entry[:language]}
          #{entry[:body]}
          ```
        TEXT
      end.join("\n")
    end

    def truncate_for_prompt(text)
      text.to_s.slice(0, PROMPT_TEXT_LIMIT)
    end

    def completed_percentage(user_course_practice)
      return '不明' unless user_course_practice.user.course

      "#{format('%.1f', user_course_practice.completed_percentage)}%"
    end

    def extract_public_response_body(content)
      if content.is_a?(String)
        parse_response_body(content)
      elsif content.respond_to?(:to_h)
        parsed = content.to_h
        parsed['body'] || parsed[:body] if parsed.is_a?(Hash)
      end
    end

    def parse_response_body(content)
      parsed = JSON.parse(content)
      parsed.is_a?(Hash) ? parsed['body'] : content
    rescue JSON::ParserError
      content
    end
  end
end
