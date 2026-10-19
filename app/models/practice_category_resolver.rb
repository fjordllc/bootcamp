# frozen_string_literal: true

class PracticeCategoryResolver
  def initialize(practice)
    @practice = practice
  end

  def category(course)
    Category.category(practice: @practice, course:) || @practice.categories.first || Category.first
  end
end
