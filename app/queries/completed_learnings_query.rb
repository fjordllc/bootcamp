# frozen_string_literal: true

class CompletedLearningsQuery < Patterns::Query
  queries Learning

  private

  def query
    relation
      .joins(practice: { categories: :courses_categories })
      .where(status: Learning.statuses[:complete], courses_categories: { course: @course })
      .distinct
      .includes(:practice)
      .order('learnings.updated_at asc')
  end

  def initialize(relation = Learning.all, course:)
    super(relation)
    @course = course
  end
end
