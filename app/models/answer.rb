# frozen_string_literal: true

class Answer < ActiveRecord::Base
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
end
