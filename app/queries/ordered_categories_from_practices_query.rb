# frozen_string_literal: true

class OrderedCategoriesFromPracticesQuery < Patterns::Query
  queries Category

  private

  def query
    return relation.none if practices.blank?

    relation
      .joins(:courses_categories)
      .where(courses_categories: { course_id: user.course_id })
      .where(id: category_ids_with_practices)
      .order('courses_categories.position ASC, categories.id ASC')
  end

  def category_ids_with_practices
    Category
      .joins(:practices)
      .where(practices: { id: practice_ids })
      .select(:id)
      .distinct
  end

  def practice_ids
    practices.pluck(:id)
  end

  def user
    # userは必須引数なので空の場合はエラーを出す
    raise ArgumentError, 'user is required' if options[:user].blank?

    options[:user]
  end

  def practices
    options[:practices]
  end
end
