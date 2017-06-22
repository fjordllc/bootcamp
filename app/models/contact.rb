class Contact < ActiveRecord::Base
  enum occupation_cd: { student: 0, working: 1, part_timer: 2, unemployed: 3 }
  enum location_cd: { local: 0, remote: 1 }
  enum programming_experience_cd: { nothing: 0, html_css: 1, something: 2, rails: 3 }
  enum work_time_cd: { week_day_10_19: 0, week_day_19: 1, holidays: 2 }
  enum work_days_cd: { five_days: 0, four_days: 1, three_days: 2 }
  validates :name,                      presence: true
  validates :name_phonetic,             presence: true
  validates :email,                     presence: true
  validates :occupation_cd,             presence: true
  validates :location_cd,               presence: true
  validates :programming_experience_cd, presence: true
  validates :application_reason,        presence: true
  validates :purpose_content,           presence: true
  validates :purpose_deadline_year,     presence: true
  validates :purpose_deadline_month,    presence: true
  validates :user_policy_agreed,        presence: true
  validates :wish_to_start_on,          presence: true
end
