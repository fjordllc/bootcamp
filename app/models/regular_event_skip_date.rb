# frozen_string_literal: true

class RegularEventSkipDate < ApplicationRecord
  belongs_to :regular_event

  validates :skip_on, presence: true
  validates :skip_on, uniqueness: { scope: :regular_event_id, message: '(%<value>s)は既に登録されています' }
end
