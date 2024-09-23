# frozen_string_literal: true

require 'test_helper'

class UserPracticeTest < ActiveSupport::TestCase
  setup do
    @user_practice = UserPractice.new(users(:kensyu))
  end

  test '#categories_with_uniq_practices' do
    user = users(:kensyu)
    categories_with_uniq_practices = @user_practice.categories_with_uniq_practices
    category_with_uniq_practices = categories_with_uniq_practices.select { |category| category.name == 'Ruby on Rails(Rails 6.1版)' }.first
    assert_equal 0, category_with_uniq_practices.practices.size

    category = user.course.categories.where(name: 'Ruby on Rails(Rails 6.1版)').first
    assert_not_equal 0, category.practices.size
  end

  test '#uniq_practice_ids' do
  end

  test '#filter_category_by_practice_ids' do
  end
end
