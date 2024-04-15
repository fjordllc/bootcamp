# frozen_string_literal: true

class RequestRetirement < ApplicationRecord
  belongs_to :requester, class_name: 'User', optional: true
  belongs_to :target_user, class_name: 'User', optional: true

  validates :requester_email, presence: true
  validates :requester_name, presence: true
  validates :requester_company_name, presence: true
  validates :target_user_name, presence: true
  validates :reason_of_request_retirement, presence: true
  validates :keep_data, inclusion: [true, false]
end
