# frozen_string_literal: true

class Buzz < ApplicationRecord
  validates :body, presence: true
end
