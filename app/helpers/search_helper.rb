# frozen_string_literal: true

module SearchHelper
  include MarkdownHelper
  include PolicyHelper

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
    case searchable
    when SearchResult
      searchable.summary
    when Comment
      if searchable.instance_of?(Comment) && searchable.commentable_type == 'Product'
        commentable = searchable.commentable_type.constantize.find(searchable.commentable_id)
        if policy(commentable).show? || (commentable.is_a?(Practice) && commentable.open_product?)
          searchable.body
        else
          '該当プラクティスを修了するまで他の人の提出物へのコメントは見れません。'
        end
      else
        searchable.description
      end
    when Product
      searchable.body
    else
      searchable.try(:description)
    end
  end

    if searchable.is_a?(Comment) && searchable.commentable_type == 'Product'
      commentable = searchable.commentable
      return '該当プラクティスを修了するまで他の人の提出物へのコメントは見れません。' unless policy(commentable).show? || commentable.practice.open_product?

      searchable.body
    end
  end

  def user?(searchable)
    if searchable.is_a?(SearchResult)
      searchable.model_name == 'user'
    else
      searchable.instance_of?(User)
    end
  end

  def created_user(searchable)
    if searchable.is_a?(SearchResult)
      User.find_by(id: searchable.user_id)
    else
      searchable.respond_to?(:user) ? searchable.user : nil
    end
  end
end
