# frozen_string_literal: true

class SkipPracticeComponent < ViewComponent::Base
  def initialize(form:, user:)
    @f = form
    @user = user
  end

  def user_categories
    display_practice_ids = []
    user_categories = @user.course.categories
    user_categories.each do |category|
      filtered_practices = category.practices.reject do |practice|
        display_practice_ids.include?(practice.id)
      end
      category.practices = filtered_practices
      display_practice_ids.concat(category.practice_ids)
    end
    user_categories
  end
end
