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
    when CorrectAnswer, Answer
      Rails.application.routes.url_helpers.question_path(searchable.question, anchor: "answer_#{searchable.id}")
    else
      helper_method = "#{searchable.class.name.underscore}_path"
      Rails.application.routes.url_helpers.send(helper_method, searchable)
    end
  end

  def filtered_message(searchable)
    if searchable.is_a?(Comment) && searchable.commentable_type == 'Product'
      commentable = searchable.commentable
      return '該当プラクティスを修了するまで他の人の提出物へのコメントは見れません。' unless policy(commentable).show? || commentable.practice.open_product?

      return md2plain_text(searchable.body)
    end

    description_or_body = searchable.try(:description) || searchable.try(:body) || ''
    md2plain_text(description_or_body)
  end

  private

  def process_special_case(comment, word)
    summary = md2plain_text(comment)
    find_match_in_text(summary, word)
  end

  def find_match_in_text(text, word)
    return text[0, EXTRACTING_CHARACTERS * 2] if word.blank?

    words = word.split(/[[:blank:]]+/).reject(&:blank?)
    first_match_position = nil

    words.each do |w|
      position = text.downcase.index(w.downcase)
      first_match_position = position if position && (first_match_position.nil? || position < first_match_position)
    end

    if first_match_position
      start_pos = [0, first_match_position - EXTRACTING_CHARACTERS].max
      end_pos = [text.length, first_match_position + EXTRACTING_CHARACTERS].min
      text[start_pos...end_pos].strip
    else
      text[0, EXTRACTING_CHARACTERS * 2]
    end
  end
end
