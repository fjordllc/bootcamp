# frozen_string_literal: true

module BuzzesHelper
  def buzzes_year(buzzes)
    buzzes.first&.published_at&.year
  end

  def group_buzzes_by_month(buzzes)
    buzzes.group_by { |b| b.published_at.month }
  end
end
