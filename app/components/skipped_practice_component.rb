# frozen_string_literal: true

class SkippedPracticeComponent < ViewComponent::Base
  def initialize(form:, user:)
    @f = form
    @user = user
    @user_course_practice = UserCoursePractice.new(user)
  end

  def skipped_practices_count(category)
    if category.practices.empty?
      '(0)'
    else
      skipped_practices_in_category = category.practice_ids & @user.practice_ids_skipped
      "(#{skipped_practices_in_category.size}/#{category.practices.size})"
    end
  end
end
