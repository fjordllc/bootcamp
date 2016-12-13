class Contact < ActiveRecord::Base
  as_enum :occupation, %i(student working  part-timer unemployed)
  as_enum :location, %i(local remote)
  as_enum :has_mac, %i(has not_have)
  as_enum :programming_experience, %i(none html_css something rails)

  validates :name,                      presence: true
  validates :name_phonetic,             presence: true
  validates :email,                     presence: true, uniqueness: true
  validates :occupation_cd,             presence: true
  validates :location_cd,               presence: true
  validates :has_mac_cd,                presence: true
  validates :work_time,                 presence: true
  validates :work_days,                 presence: true
  validates :programming_experience_cd, presence: true
  validates :application_reason,        presence: true
  validates :user_policy_agreed,        presence: true

end
