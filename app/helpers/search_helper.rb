# frozen_string_literal: true

module SearchHelper
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
      document = searchable.question
      polymorphic_url(document).to_s
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
        '該当プラクティスを完了するまで他の人の提出物へのコメントは見れません。'
      end
    else
      searchable.description
    end
  end

  def comment_or_answer?(searchable)
    searchable.is_a?(Comment) || searchable.is_a?(Answer)
  end
end
