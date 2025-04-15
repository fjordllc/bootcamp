# frozen_string_literal: true

module SearchHelper
  include MarkdownHelper

  EXTRACTING_CHARACTERS = 50

  def searchable_summary(comment, word = '')
    return '' if comment.nil?
    comment_str = comment.to_s

    if comment_str.include?('|') && !comment_str.include?('```')
      escaped_comment = escape_special_chars(comment_str)
      return find_match_in_text(escaped_comment, word)
    end

    plain_text_summary = markdown_to_plain_text(comment_str)

    find_match_in_text(plain_text_summary, word)
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
    if searchable.instance_of?(Comment)
      document = searchable.commentable_type.constantize.find(searchable.commentable_id)
      "#{polymorphic_url(document)}#comment_#{searchable.id}"
    elsif searchable.instance_of?(Answer) || searchable.instance_of?(CorrectAnswer)
      document = Question.find(searchable.question.id)
      "#{polymorphic_url(document)}#answer_#{searchable.id}"
    else
      polymorphic_url(searchable)
    end
  end

  def filtered_message(searchable)
    if searchable.instance_of?(Comment) && searchable.commentable_type == 'Product'
      commentable = Product.find(searchable.commentable_id)
      if policy(commentable).show? || commentable.practice.open_product?
        searchable.description
      else
        '該当プラクティスを修了するまで他の人の提出物へのコメントは見れません。'
      end
    else
      searchable.description
    end
  end

  def comment_or_answer?(searchable)
    searchable.is_a?(Comment) || searchable.is_a?(Answer)
  end

  def talk?(searchable)
    searchable.instance_of?(User) && searchable.talk.present?
  end

  def user?(searchable)
    searchable.instance_of?(User)
  end

  def created_user(searchable)
    searchable.respond_to?(:user) ? searchable.user : nil
  end

  private

  def escape_special_chars(text)
    text.gsub('&', '&amp;')
        .gsub('<', '&lt;')
        .gsub('>', '&gt;')
  end

  def find_match_in_text(text, word)
    return text if word.blank? || text.blank?
    words = word.split(/[[:space:]]+/).compact.reject(&:empty?)
    return text if words.blank?

    words_pattern = words.map { |keyword| Regexp.escape(keyword) }.join('|')
    words_regexp = Regexp.new(words_pattern, Regexp::IGNORECASE)
    match = words_regexp.match(text)
    return text if match.nil?

    begin_offset = (match.begin(0) - EXTRACTING_CHARACTERS).clamp(0, Float::INFINITY)
    text.slice(begin_offset..)&.strip || ''
  end
end
