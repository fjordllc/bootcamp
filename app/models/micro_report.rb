# frozen_string_literal: true

class MicroReport < ApplicationRecord
  include Reactionable

  belongs_to :user
  belongs_to :comment_user, class_name: 'User'
  validates :content, presence: true

  before_validation :set_default_comment_user, on: :create

  private

  def set_default_comment_user
    self.comment_user ||= user
  end
end
