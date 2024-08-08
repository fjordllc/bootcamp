# frozen_string_literal: true

class SkippedPracticeComponent < ViewComponent::Base
  def initialize(form:, user:)
    @f = form
    @user = user
  end

  def user_categories_with_uniq_practices
    user_categories = @user.course.categories
    display_practice_ids = []
    user_categories_with_uniq_practices = []
    user_categories.each do |category|
      copy_category = category.dup
      category.practices.each do |practice|
        if !display_practice_ids.include?(practice.id)
          copy_category.practices << practice
          display_practice_ids << practice.id
        end
      end
      user_categories_with_uniq_practices << copy_category
    end

    user_categories_with_uniq_practices
  end
end
