# frozen_string_literal: true

class Participation < ApplicationRecord
  belongs_to :user
  belongs_to :event

  scope :disabled, -> { where(enable: false) }

  def waited?
    saved_change_to_attribute?('enable', from: false, to: true)
  end
end
