# frozen_string_literal: true

class RequestRetirement < ApplicationRecord
  belongs_to :user
  belongs_to :target_user, class_name: 'User'

  validates :target_user_id, presence: true, uniqueness: { message: 'は既に申請済みです' }
  validates :reason, presence: true
  validates :keep_data, inclusion: [true, false]
end
