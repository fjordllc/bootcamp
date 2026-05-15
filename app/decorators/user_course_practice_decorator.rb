# frozen_string_literal: true

module UserCoursePracticeDecorator
  def cached_completed_percentage
    Rails.cache.fetch "/model/user_course_practice/#{user.id}/completed_percentage" do
      completed_percentage
    end
  end

  def cached_completed_fraction
    Rails.cache.fetch "/model/user_course_practice/#{user.id}/completed_fraction" do
      "修了: #{completed_practices.size} （必須: #{completed_required_practices.size}/#{required_practices.size}）"
    end
  end

  def cached_completed_fraction_in_metas
    Rails.cache.fetch "/model/user_course_practice/#{user.id}/completed_fraction_in_metas" do
      "#{completed_practices.size} （必須:#{completed_required_practices.size}）"
    end
  end
end
