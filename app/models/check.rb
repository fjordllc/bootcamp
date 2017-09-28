class Check < ApplicationRecord
  belongs_to :user
  belongs_to :report
  after_create CheckCallbacks.new
  validates :user_id, presence: true
  validates :report_id, presence: true
  alias_method :sender, :user

  def reciever
    report.user
  end
end
