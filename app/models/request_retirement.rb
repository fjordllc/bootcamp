# frozen_string_literal: true

class RequestRetirement < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :target_user, class_name: 'User', optional: true

  validates :target_user_id, presence: true, uniqueness: { message: 'は既に申請済みです' }
  validates :reason, presence: true
  validates :keep_data, inclusion: [true, false]
end
