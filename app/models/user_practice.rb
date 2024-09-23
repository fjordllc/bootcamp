# frozen_string_literal: true

class UserPractice
  attr_reader :user

  delegate :courses, to: :user

  def initialize(user)
    @user = user
  end

  def uniq_practice_ids
    @user.course.practices.uniq.pluck(:id)
  end

  def filter_category_by_practice_ids(category, practice_ids)
    copy_category = category.dup
    category.practices.each do |practice|
      copy_category.practices << practice if practice_ids.delete(practice.id)
    end
    [copy_category, practice_ids]
  end

  def categories_with_uniq_practices
    user_categories_with_uniq_practices = []
    practice_ids = uniq_practice_ids
    @user.course.categories.each do |category|
      copy_category, practice_ids = filter_category_by_practice_ids(category, practice_ids)
      user_categories_with_uniq_practices << copy_category
    end
    user_categories_with_uniq_practices
  end
end
