# frozen_string_literal: true

class UserCoursePractice
  attr_reader :user

  delegate :courses, to: :user
  MAX_PERCENTAGE = 100

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

  def sorted_practices
    @user.course.practices.order('courses_categories.position', 'categories_practices.position')
  end

  def skipped_practice_ids
    @user.skipped_practices.pluck(:practice_id)
  end

  # def completed_percentage
  #   completed_required_practices_size.to_f / required_practices_size * MAX_PERCENTAGE
  # end

  # def required_practices_size
  #   practices_include_progress.pluck(:id).uniq.size - required_practices_size_with_skip
  # end

  # def completed_required_practices_size
  #   practices_include_progress.joins(:learnings)
  #                             .merge(Learning.complete.where(user_id: id)).pluck(:id).uniq.size
  # end

  # def completed_practices_size_by_category
  #   Practice
  #     .joins({ categories: :categories_practices }, :learnings)
  #     .where(
  #       learnings: {
  #         user_id: id,
  #         status: 'complete'
  #       }
  #     )
  #     .group('categories_practices.category_id')
  #     .count('DISTINCT practices.id')
  # end

  # private

  # def practices_include_progress
  #   course.practices.where(include_progress: true)
  # end

  # def required_practices_size_with_skip
  #   course.practices.where(id: practice_ids_skipped, include_progress: true).size
  # end
end
