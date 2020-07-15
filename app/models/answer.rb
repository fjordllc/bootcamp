# frozen_string_literal: true

class Answer < ApplicationRecord
  include Reactionable
  include Searchable

  belongs_to :user, touch: true
  belongs_to :question
  alias_method :sender, :user

  after_create AnswerCallbacks.new

  validates :description, presence: true
  validates :user, presence: true

  columns_for_keyword_search :description

  def receiver
    self.question.user
  end

  def path
    Rails.application.routes.url_helpers.polymorphic_path(question, anchor: anchor)
  end
end
