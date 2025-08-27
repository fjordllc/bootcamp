# frozen_string_literal: true

require 'test_helper'

class CategoryFromPracticesQueryTest < ActiveSupport::TestCase
  test 'should return categories associated with practices and user course' do
    user = users(:komagata)
    practices = [practices(:practice1), practices(:practice2)]

    result = CategoryFromPracticesQuery.new(user:, practices:).call

    assert result.is_a?(ActiveRecord::Relation)
    assert result.count.positive?

    category_ids = result.pluck(:id)
    assert_includes category_ids, categories(:category2).id
    assert_includes category_ids, categories(:category4).id
  end

  test 'should return empty relation when practices are blank' do
    user = users(:komagata)
    empty_practices = []

    result = CategoryFromPracticesQuery.new(user:, practices: empty_practices).call

    assert_equal 0, result.count
    assert result.is_a?(ActiveRecord::Relation)
  end

  test 'should return empty relation when practices are nil' do
    user = users(:komagata)

    result = CategoryFromPracticesQuery.new(user:, practices: nil).call

    assert_equal 0, result.count
    assert result.is_a?(ActiveRecord::Relation)
  end

  test 'should order results by courses_categories position' do
    user = users(:komagata)
    practices = [practices(:practice1), practices(:practice9)]

    result = CategoryFromPracticesQuery.new(user:, practices:).call

    assert_equal 2, result.count

    categories_array = result.to_a
    first_category = categories_array.first
    second_category = categories_array.second

    assert_equal categories(:category2).id, first_category.id
    assert_equal categories(:category4).id, second_category.id
  end

  test 'should only return categories for user course' do
    user1 = users(:komagata)
    user2 = users(:'unity-course')
    practices = [practices(:practice1)]

    result1 = CategoryFromPracticesQuery.new(user: user1, practices:).call
    result2 = CategoryFromPracticesQuery.new(user: user2, practices:).call

    assert result1.count.positive?
    assert result2.count.zero?
  end

  test 'should return unique categories from multiple practices' do
    user = users(:komagata)
    practices = [practices(:practice2), practices(:practice4), practices(:practice9)]

    result = CategoryFromPracticesQuery.new(user:, practices:).call

    category_ids = result.pluck(:id)
    assert_equal category_ids.uniq.size, category_ids.size

    assert_equal 1, result.count
    assert_equal categories(:category4).id, result.first.id
  end
end
