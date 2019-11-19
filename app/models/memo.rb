# frozen_string_literal: true

class Memo < ApplicationRecord
  validates :date, uniqueness: true
end
