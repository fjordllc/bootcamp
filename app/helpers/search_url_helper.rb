# frozen_string_literal: true

module SearchUrlHelper
  def searchable_url(searchable)
    case searchable
    when Comment
      comment_url(searchable)
    when Searcher::SearchRow
      search_row_url(searchable)
    when Answer, CorrectAnswer
      Rails.application.routes.url_helpers.question_path(searchable.question, anchor: "answer_#{searchable.id}")
    else
      default_url(searchable)
    end
  end

  private

  def comment_url(comment)
    "#{Rails.application.routes.url_helpers.polymorphic_path(comment.commentable)}#comment_#{comment.id}"
  end

  def search_row_url(row)
    case row.record_type
    when 'comments'
      comment_url(row)
    when 'answers', 'correct_answers'
      return nil if row.commentable_id.blank?

      Rails.application.routes.url_helpers.question_path(row.commentable_id, anchor: "answer_#{row.id}")
    else
      helper_method = "#{row.record_type.singularize}_path"
      if Rails.application.routes.url_helpers.respond_to?(helper_method)
        Rails.application.routes.url_helpers.send(helper_method, row.id)
      else
        Rails.logger.warn "Unknown helper method: #{helper_method} for record_type: #{row.record_type}"
        nil
      end
    end
  end

  def default_url(record)
    helper_method = "#{record.class.name.underscore}_path"
    Rails.application.routes.url_helpers.send(helper_method, record)
  end
end
