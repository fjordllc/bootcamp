class Contact < ActiveRecord::Base
  validates :name,                   presence: true
  validates :name_phonetic,          presence: true
  validates :email,                  presence: true, uniqueness: true
  validates :occupation,             presence: true
  validates :work_place,             presence: true
  validates :has_mac,                presence: true
  validates :work_time,              presence: true
  validates :work_days,              presence: true
  validates :programming_experience, presence: true
  validates :application_reason,     presence: true
  validates :user_policy_agreed,     presence: true

end
