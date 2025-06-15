# frozen_string_literal: true

class CompletedLearningsQuery < Patterns::Query
  queries Learning

  private

  def query
    relation
      .joins(practice: { categories: :courses_categories })
      .where(status: 'complete', courses_categories: { course: @course })
      .includes(:practice)
      .order('learnings.updated_at asc')
  end

  def initialize(relation = Learning.all, course:)
    super(relation)
    @course = course
  end
end
