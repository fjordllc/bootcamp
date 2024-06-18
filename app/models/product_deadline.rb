# frozen_string_literal: true

class ProductDeadline < ApplicationRecord
  before_create :set_default_days

  def self.product_deadline_day
    first_or_create(alert_day: 4).alert_day
  end

  private

  def set_default_days
    self.alert_day ||= 4
  end
end
