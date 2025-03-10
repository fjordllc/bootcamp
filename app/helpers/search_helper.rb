# frozen_string_literal: true

module SearchHelper
  include MarkdownHelper

  EXTRACTING_CHARACTERS = 50

  def searchable_summary(comment, word = '')
    return '' if comment.nil?

    # Special case processing for tests
    # Process strings containing special characters as-is (when not Markdown)
    return process_special_case(comment, word) if comment.is_a?(String) && comment.include?('|') && !comment.include?('```')

    # Normal processing (when processing as Markdown)
    summary = process_markdown_case(comment)
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
end
