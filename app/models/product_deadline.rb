# frozen_string_literal: true

class ProductDeadline < ApplicationRecord
  before_create :set_default_days

  private

  def set_default_days
    self.alert_day ||= 4
  end
end
