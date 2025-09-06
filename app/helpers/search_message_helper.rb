# frozen_string_literal: true

module SearchMessageHelper
  def filtered_message_for_stub(searchable)
    content =
      case searchable.record_type
      when 'answers', 'correct_answers'
        content_from_answer_or_correct(searchable)
      when 'comments'
        content_from_comment(searchable)
      else
        searchable.description.presence || searchable.body.presence || ''
      end

    md2plain_text(content.to_s)
  end

  def product_comment_visible?(product)
    return false unless product

    policy(product).show? || product.try(:practice)&.open_product?
  end

  def message_for_comment(searchable)
    md2plain_text(content_from_comment(searchable))
  end

  private

  def content_from_answer_or_correct(searchable)
    searchable.body.presence || searchable.description.presence ||
      searchable.commentable.try(:description).presence ||
      searchable.commentable.try(:body).presence ||
      searchable.commentable.try(:title).presence
  end

  def content_from_comment(searchable)
    if searchable.commentable_type == 'Product'
      prod = searchable.commentable
      return '該当プラクティスを修了するまで他の人の提出物へのコメントは見れません。' unless product_comment_visible?(prod)

      return searchable.body.to_s
    end

    searchable.body.presence || searchable.commentable&.try(:title).presence || ''
  end
end
