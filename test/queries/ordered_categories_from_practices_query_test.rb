# frozen_string_literal: true

require 'test_helper'

class OrderedCategoriesFromPracticesQueryTest < ActiveSupport::TestCase
  test 'should return categories associated with practices and user course' do
    user = users(:komagata) # course1のユーザー
    practices = Practice.where(id: [practices(:practice1).id, practices(:practice2).id])
    result = OrderedCategoriesFromPracticesQuery.call(user:, practices:)

    assert_kind_of ActiveRecord::Relation, result
    assert result.exists?

    # practice1はcategory2に、practice2はcategory4に関連付けられている
    # komagataのcourse1にはcategory2とcategory4の両方が含まれている
    category_ids = result.pluck(:id)
    assert_includes category_ids, categories(:category2).id
    assert_includes category_ids, categories(:category4).id
  end

  test 'should return empty relation when practices are blank' do
    user = users(:komagata)
    empty_practices = Practice.none

    result = OrderedCategoriesFromPracticesQuery.call(user:, practices: empty_practices)

    assert_empty result, '空であるべき結果にカテゴリが含まれています。'
    assert_kind_of ActiveRecord::Relation, result
  end

  test 'should return empty relation when practices are nil' do
    user = users(:komagata)

    result = OrderedCategoriesFromPracticesQuery.call(user:, practices: nil)

    assert_empty result, '空であるべき結果にカテゴリが含まれています。'
    assert_kind_of ActiveRecord::Relation, result
  end

  test 'should order results by courses_categories position' do
    user = users(:komagata)
    practices = Practice.where(id: [practices(:practice1).id, practices(:practice9).id])

    result = OrderedCategoriesFromPracticesQuery.call(user:, practices:)

    assert_equal 2, result.size

    # course1では category2(position: 2) < category4(position: 4) の順序
    assert_equal [categories(:category2).id, categories(:category4).id], result.pluck(:id)
  end

  test 'should only return categories for user course' do
    user1 = users(:komagata) # course1のユーザー
    user2 = users(:'unity-course') # course2のユーザー
    practices = Practice.where(id: practices(:practice1).id) # category2に関連

    result1 = OrderedCategoriesFromPracticesQuery.call(user: user1, practices:)
    result2 = OrderedCategoriesFromPracticesQuery.call(user: user2, practices:)

    # course1にはcategory2が含まれているが、course2には含まれていない
    assert result1.exists?
    assert_not result2.exists?
  end

  test 'should return unique categories from multiple practices' do
    user = users(:komagata)
    practices = Practice.where(id: [practices(:practice2).id, practices(:practice4).id, practices(:practice9).id]) # 全てcategory4

    result = OrderedCategoriesFromPracticesQuery.call(user:, practices:)

    category_ids = result.pluck(:id)
    assert_equal category_ids.uniq.size, category_ids.size

    assert_equal 1, category_ids.size
    assert_equal categories(:category4).id, category_ids.first
  end
end
