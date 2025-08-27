# frozen_string_literal: true

class CategoryFromPracticesQuery < Patterns::Query
  queries Category

  private

  def initialize(relation = Category.all, user:, practices:)
    super(relation)
    @user = user
    @practices = practices
  end

  def query
    return relation.none if @practices.blank?

    practice_ids = @practices.pluck(:id)

    relation
      .joins(:courses_categories)
      .joins(practices: :categories_practices)
      .where(practices: { id: practice_ids })
      .where(courses_categories: { course_id: @user.course_id })
      .order('courses_categories.position ASC, categories_practices.position ASC')
  end
end
