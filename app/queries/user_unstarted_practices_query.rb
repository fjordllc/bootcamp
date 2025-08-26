# frozen_string_literal: true

class UserUnstartedPracticesQuery < Patterns::Query
  queries Practice

  private

  def initialize(relation = Practice.all, user:)
    super(relation)
    @user = user
    @course_id = user.course_id
  end

  def query
    relation
      .joins(categories_practices: { category: :courses_categories })
      .where(courses_categories: { course_id: @course_id })
      .where.not(id: learned_practice_ids)
      .select('practices.*')
      .order('courses_categories.position ASC, categories_practices.position ASC')
  end

  def learned_practice_ids
    statuses = Learning.statuses.values_at(:started, :submitted, :complete)
    Learning.where(user_id: @user.id, status: statuses).select(:practice_id)
  end
end
