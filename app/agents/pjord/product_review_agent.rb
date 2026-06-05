# frozen_string_literal: true

class Pjord::ProductReviewAgent < Pjord::Agent
  OTHER_PRODUCTS_LIMIT = 10
  PROMPT_TEXT_LIMIT = 2_000

  schema PjordProductReviewResponse
  instructions

  class << self
    def review(product)
      extract_public_response_body(new.ask(message(product)).content).presence
    end

    private

    def message(product)
      user_course_practice = UserCoursePractice.new(product.user)
      <<~TEXT
        以下の情報を参考に、提出物へのレビューコメントを書いてください。

        ## 提出物URL
        #{Rails.application.routes.url_helpers.product_url(product)}

        ## 提出者
        - ログイン名: #{product.user.login_name}
        - 名前: #{product.user.name}
        - プロフィール: #{product.user.description.presence || '未入力'}
        - 進捗率: #{completed_percentage(user_course_practice)}

        ## プラクティス
        - タイトル: #{product.practice.title}
        - ゴール:
        #{truncate_for_prompt(product.practice.goal)}
        - 説明:
        #{truncate_for_prompt(product.practice.description)}

        ## 提出物
        #{truncate_for_prompt(product.body)}

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

    def truncate_for_prompt(text)
      text.to_s.slice(0, PROMPT_TEXT_LIMIT)
    end

    def completed_percentage(user_course_practice)
      return '不明' unless user_course_practice.user.course

      "#{format('%.1f', user_course_practice.completed_percentage)}%"
    end
  end
end
