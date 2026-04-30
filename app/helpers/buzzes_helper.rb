# frozen_string_literal: true

module BuzzesHelper
  def group_buzzes_by_month(buzzes)
    buzzes.group_by { |b| b.published_at.month }
  end
end
