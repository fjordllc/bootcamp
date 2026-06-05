# frozen_string_literal: true

class Pjord::ProductReviewAgent < Pjord::Agent
  OTHER_PRODUCTS_LIMIT = 10
  PROMPT_TEXT_LIMIT = 2_000

  schema PjordProductReviewResponse
  instructions

  class << self
    def review(product)
      agent = new
      response = response_content(agent.ask(message(product)).content)
      return response[:body] if sufficient_review?(response)

      retry_response = response_content(agent.ask(retry_message(product, response)).content)
      retry_response[:body].presence
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

    def retry_message(product, previous_response)
      <<~TEXT
        直前のレビューコメントは、提出物の内容を具体的に確認した点が構造化されていないため不十分です。

        ## 直前のレビューコメント本文
        #{previous_response[:body].presence || 'なし'}

        ## 直前の具体的な確認点
        #{previous_response[:reviewed_points].presence || 'なし'}

        ## やり直しの条件
        - reviewed_points には、提出物本文、URL先の内容、模範解答、過去コメントなどから確認した具体的な点を1つ以上入れてください。
        - body には reviewed_points の内容を反映したレビューコメントを書いてください。
        - 改善点が見つからない場合も、何を確認して問題ないと判断したかを書いてください。

        #{message(product)}
      TEXT
    end

    def response_content(content)
      parsed =
        if content.respond_to?(:to_h)
          content.to_h
        elsif content.is_a?(String)
          JSON.parse(content)
        else
          {}
        end

      {
        body: extract_public_response_body(parsed).presence,
        reviewed_points: Array.wrap(parsed['reviewed_points'] || parsed[:reviewed_points]).filter_map { |point| point.to_s.presence }
      }
    rescue JSON::ParserError
      {
        body: extract_public_response_body(content).presence,
        reviewed_points: []
      }
    end

    def sufficient_review?(response)
      response[:body].present? && response[:reviewed_points].present?
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
