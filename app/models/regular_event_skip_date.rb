# frozen_string_literal: true

class RegularEventSkipDate < ApplicationRecord
  belongs_to :regular_event

  validates :skip_on, presence: true
end
