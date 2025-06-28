# frozen_string_literal: true

module ReportsHelper
  SUCCESS = (0..1)
  LAST_UNCHECKED_REPORT_COUNT = 1
  PRIMARY = (2..4)
  WARNING = (5..9)
  DANGER = (10..)

  def practice_options(categories)
    categories.flat_map do |category|
      category.practices.map do |practice|
        ["[#{category.name}] #{practice.title}", practice.id]
      end
    end
  end

  def practice_options_within_course
    user_course_categories = current_user.course.categories.includes(:practices)
    user_course_categories.flat_map(&:practices).map { |practice| [practice.title, practice.id] }.uniq
  end

  def convert_to_hour_minute(time)
    hour = (time / 60).to_i
    minute = (time % 60).round

    if minute.zero?
      "#{hour}時間"
    else
      "#{hour}時間#{minute}分"
    end
  end

  def convert_to_ceiled_hour(time)
    ceiled_hour = (time / 60.0).ceil.to_i
    "#{ceiled_hour}時間"
  end

  def category_practices(report)
    report.practices.eager_load(:categories).order('categories_practices.position')
  end
end
