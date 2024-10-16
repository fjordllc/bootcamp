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

  def categories_for_skip_practice
    filterd_categories = []
    practice_ids = uniq_practice_ids
    @user.course.categories.each do |category|
      copy_category, practice_ids = filter_category_by_practice_ids(category, practice_ids)
      filterd_categories << copy_category
    end
    filterd_categories
  end

  def sorted_practices
    @user.course.practices.order('courses_categories.position', 'categories_practices.position')
  end

  def skipped_practice_ids
    @user.skipped_practices.pluck(:practice_id)
  end

  def category_active_or_unstarted_practice
    if @user.active_practices.present?
      category_having_active_practice
    elsif unstarted_practices.present?
      category_having_unstarted_practice
    end
  end

  def required_practices
    Practice
      .joins(categories: { courses: :users })
      .where(users: { id: user.id }, include_progress: true)
      .where.not(id: skipped_practice_ids).distinct
  end

  def completed_practices
    Practice
      .joins({ categories: { courses: :users } }, :learnings)
      .where(
        users: { id: user.id },
        learnings: {
          user_id: user.id,
          status: 'complete'
        }
      )
      .distinct
  end

  def completed_required_practices
    Practice
      .joins({ categories: { courses: :users } }, :learnings)
      .where(
        users: { id: user.id },
        learnings: {
          user_id: user.id,
          status: 'complete'
        },
        include_progress: true
      )
      .where.not(id: skipped_practice_ids).distinct
  end

  def completed_percentage
    completed_required_practices.size.to_f / required_practices.size * MAX_PERCENTAGE
  end

  def completed_practices_size_by_category
    Practice
      .joins({ categories: :categories_practices }, :learnings)
      .where(
        learnings: {
          user_id: user.id,
          status: 'complete'
        }
      )
      .group('categories_practices.category_id')
      .count('DISTINCT practices.id')
  end

  private

  def unstarted_practices
    practices = @user.course.practices
    @unstarted_practices ||= practices -
                             practices.joins(:learnings).where(learnings: { user_id: @user.id, status: :started })
                                      .or(practices.joins(:learnings).where(learnings: { user_id: @user.id, status: :submitted }))
                                      .or(practices.joins(:learnings).where(learnings: { user_id: @user.id, status: :complete }))
  end

  def category_having_active_practice
    @user.active_practices&.first&.categories&.first
  end

  def category_having_unstarted_practice
    unstarted_practices&.first&.categories&.first
  end
end
