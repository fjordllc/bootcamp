# frozen_string_literal: true

class FAQ < ApplicationRecord
  validates :answer, presence: true, uniqueness: { scope: :question }
  validates :question, presence: true, uniqueness: true
  validates :category, presence: true

  default_scope -> { order(:position) }
  acts_as_list

  enum category: {
    study_content: 0,
    study_environment: 1,
    fee: 2,
    find_job: 3,
    join: 4,
    withdrawal_hibernation_graduation: 5,
    corporate_use: 6
  }, _prefix: true
end
