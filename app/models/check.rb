class Check < ApplicationRecord
  belongs_to :user, foreign_key: 'user_id'
  belongs_to :report, foreign_key: 'report_id'

  validates :user_id, presence: true
  validates :report_id, presence: true

end
