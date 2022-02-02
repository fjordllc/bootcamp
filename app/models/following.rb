# frozen_string_literal: true

class Following < ApplicationRecord
  belongs_to :follower, class_name: 'User'
  belongs_to :followed, class_name: 'User'
  validates :follower_id, presence: true, uniqueness: { scope: :followed_id, message: '設定が重複しています' }
  validates :followed_id, presence: true
end
