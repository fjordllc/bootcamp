# frozen_string_literal: true

class MicroReport < ApplicationRecord
  include Reactionable

  belongs_to :user
  belongs_to :comment_user, class_name: 'User'
  validates :content, presence: true
end
