# frozen_string_literal: true

class Answer < ApplicationRecord
  include Reactionable
  include Searchable
  include Mentioner

  belongs_to :user, touch: true
  belongs_to :question, touch: false
  alias sender user

  after_create AnswerCallbacks.new
  after_save AnswerCallbacks.new
  after_destroy AnswerCallbacks.new

  validates :description, presence: true
  validates :user, presence: true

  columns_for_keyword_search :description

  mentionable_as :description

  def receiver
    question.user
  end

  def path
    Rails.application.routes.url_helpers.polymorphic_path(question, anchor: anchor)
  end
end
