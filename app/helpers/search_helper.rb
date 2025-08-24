# frozen_string_literal: true

module SearchHelper
  include MarkdownHelper
  include PolicyHelper

  EXTRACTING_CHARACTERS = 50

  def searchable_summary(comment, word = '')
    return '' if comment.nil?

    return process_special_case(comment, word) if comment.is_a?(String) && comment.include?('|') && !comment.include?('```')

    summary = md2plain_text(comment)
    find_match_in_text(summary, word)
  end

  def matched_document(searchable)
    if searchable.instance_of?(Comment)
      searchable.commentable_type.constantize.find(searchable.commentable_id)
    elsif searchable.instance_of?(Answer) || searchable.instance_of?(CorrectAnswer)
      searchable.question
    else
      searchable
    end
  end

  def searchable_url(searchable)
    case searchable
    when Comment
      "#{Rails.application.routes.url_helpers.polymorphic_path(searchable.commentable)}#comment_#{searchable.id}"

    when Searcher::SearchRow
      case searchable.record_type
      when 'comments'
        "#{Rails.application.routes.url_helpers.polymorphic_path(searchable.commentable)}#comment_#{searchable.id}"
      when 'answers', 'correct_answers'
        Rails.application.routes.url_helpers.question_path(searchable.commentable_id, anchor: "answer_#{searchable.id}")
      else
        helper_method = "#{searchable.record_type.singularize}_path"
        Rails.application.routes.url_helpers.send(helper_method, searchable.id)
      end

    when Answer, CorrectAnswer
      Rails.application.routes.url_helpers.question_path(searchable.question, anchor: "answer_#{searchable.id}")

    else
      helper_method = "#{searchable.class.name.underscore}_path"
      Rails.application.routes.url_helpers.send(helper_method, searchable)
    end
  end

  def filtered_message(searchable)
    if defined?(Searcher::SearchRow) && searchable.is_a?(Searcher::SearchRow)
      case searchable.record_type
      when 'answers', 'correct_answers'
        content = searchable.body.presence || searchable.description.presence
        if content.blank?
          answer = Answer.find_by(id: searchable.id)
          content = answer.body.presence || answer.description.presence if answer
        end

        if content.blank? && (q = searchable.commentable)
          content = q.try(:description).presence || q.try(:body).presence || q.try(:title).presence
        end

      when 'comments'
        if searchable.commentable_type == 'Product'
          prod = searchable.commentable
          return '該当プラクティスを修了するまで他の人の提出物へのコメントは見れません。' unless prod && (policy(prod).show? || prod.try(:practice)&.open_product?)

          return md2plain_text(searchable.body.to_s)
        end

        content = searchable.body.presence || searchable.commentable&.try(:title).presence || ''

      else
        content = searchable.description.presence || searchable.body.presence || ''
      end
      return md2plain_text(content.to_s)
    end

    case searchable
    when Answer, CorrectAnswer
      searchable.body || ''
    when Comment
      if searchable.commentable_type == 'Product'
        commentable = searchable.commentable
        return '該当プラクティスを修了するまで他の人の提出物へのコメントは見れません。' unless policy(commentable).show? || commentable.practice.open_product?

        return md2plain_text(searchable.body)
      end
      md2plain_text(searchable.body || searchable.commentable&.title || '')
    else
      description_or_body = searchable.try(:description) || searchable.try(:body) || ''
      md2plain_text(description_or_body)
    end
  end

  def created_user(searchable)
    if searchable.is_a?(SearchResult)
      return nil if searchable.user_id.blank?

      searchable.users_by_id_map[searchable.user_id]
    else
      searchable.respond_to?(:user) ? searchable.user : nil
    end
  end

  def extract_user_id_match(result, word)
    user_id = word.delete_prefix('user:')
    return match_by_user_object(result, user_id) if result.respond_to?(:user) && result.user.present?

    match_by_last_updated_user_id(result, user_id)
  end

  def match_by_user_object(result, user_id)
    result.user&.login_name&.casecmp?(user_id)
  end

  def match_by_last_updated_user_id(result, user_id)
    return false unless result.respond_to?(:last_updated_user_id) && result.last_updated_user_id.present?

    user = User.find_by(id: result.last_updated_user_id)
    user&.login_name&.casecmp?(user_id)
  end

  def visible_to_user?(searchable, current_user)
    case searchable
    when Talk
      current_user.admin? || searchable.user_id == current_user.id
    when Comment
      if searchable.commentable.is_a?(Talk)
        current_user.admin? || searchable.commentable.user_id == current_user.id
      else
        true
      end
    when User, Practice, Page, Event, RegularEvent, Announcement, Report, Product, Question, Answer
      true
    else
      false
    end
  end

  def delete_private_comment!(searchables)
    searchables.reject do |searchable|
      searchable.instance_of?(Comment) && searchable.commentable.class.in?([Talk, Inquiry, CorporateTrainingInquiry])
    end
  end

  def search_model_name(type)
    return nil if type == :all

    type.to_s.camelize.singularize
  end

  def filter_by_keywords(results, words)
    return results if words.empty?

    (results || []).select { |result| words.all? { |word| result_matches_keyword?(result, word) } }
                   .sort_by(&:updated_at)
                   .reverse
  end

  def result_matches_keyword?(result, word)
    return extract_user_id_match(result, word) if word.match?(/^user:/)

    word_downcase = word.downcase
    [result.try(:title), result.try(:body), result.try(:description)]
      .compact
      .any? { |field| field.downcase.include?(word_downcase) }
  end
end
