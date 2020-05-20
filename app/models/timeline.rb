# frozen_string_literal: true

class Timeline < ApplicationRecord
  belongs_to :user

  validates :description, presence: true
end
