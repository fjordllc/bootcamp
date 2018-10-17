# frozen_string_literal: true

class Answer < ActiveRecord::Base
  belongs_to :user, touch: true
  belongs_to :question
  alias_method :sender, :user
  
  after_create AnswerCallbacks.new

  validates :description, presence: true
  validates :user, presence: true

  def reciever
    self.question.user
  end
end
