# frozen_string_literal: true

class CodingTestSubmission < ApplicationRecord
  belongs_to :coding_test
  belongs_to :user

  has_one :practice, through: :coding_test

  validates :coding_test_id, uniqueness: { scope: :user_id }
end
