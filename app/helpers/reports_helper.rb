# frozen_string_literal: true

module ReportsHelper
  def recent_reports
    @recent_reports ||= Report.eager_load(:user, :checks).order(updated_at: :desc, id: :desc).limit(15)
  end

  def practice_options(categories)
    categories.flat_map do |category|
      category.practices.map do |practice|
        ["[#{category.name}] #{practice.title}", practice.id]
      end
    end
  end
end
