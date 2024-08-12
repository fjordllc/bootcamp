# frozen_string_literal: true

class CodingTestSubmission < ApplicationRecord
  belongs_to :coding_test
  belongs_to :user

  validates :coding_test_id, uniqueness: { scope: :user_id }
end
