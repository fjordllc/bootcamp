# frozen_string_literal: true

module PracticeBody
  extend ActiveSupport::Concern

  def all_text
    [title, description, goal].join("\n")
  end

  def body
    [description, goal].join("\n")
  end

  def text_for_embedding
    text = [title, description, goal].compact.join("\n\n")
    truncate_for_embedding(text)
  end

  def product(user)
    products.find_by(user:)
  end

  def exists_learning?(user)
    Learning.exists?(
      user:,
      practice_id: id
    )
  end

  def learning(user)
    learnings.find_by(user:)
  end
end
