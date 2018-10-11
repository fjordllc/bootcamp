# frozen_string_literal: true

class Contact < ActiveRecord::Base
  enum occupation_cd: { student: 0, working: 1, part_timer: 2, unemployed: 3 }
  enum location_cd: { local: 0, remote: 1 }
  enum has_mac_cd: { has: 0, not_have: 1 }
  enum programming_experience_cd: { nothing: 0, html_css: 1, something: 2, rails: 3 }
  validates :name,                      presence: true
  validates :name_phonetic,             presence: true
  validates :email,                     presence: true
  validates :occupation_cd,             presence: true
  validates :location_cd,               presence: true
  validates :has_mac_cd,                presence: true
  validates :work_time,                 presence: true
  validates :work_days,                 presence: true
  validates :programming_experience_cd, presence: true
  validates :application_reason,        presence: true
  validates :user_policy_agreed,        presence: true
end
