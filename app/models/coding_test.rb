# frozen_string_literal: true

class CodingTest < ApplicationRecord
  enum language: {
    ruby: 1,
    javascript: 2
  }, _prefix: true

  belongs_to :practice
  belongs_to :user
  has_many :coding_test_cases, dependent: :destroy
  has_many :coding_test_submissions, dependent: :destroy

  accepts_nested_attributes_for :coding_test_cases

  acts_as_list scope: :practice

  validates :language, presence: true
  validates :title, presence: true
  validates :description, presence: true

  validate :no_test_cases

  def passed_by?(user)
    coding_test_submissions.exists?(user:)
  end

  private

  def no_test_cases
    return if coding_test_cases.any?

    errors.add(:base, 'テストケースがありません')
  end
end
