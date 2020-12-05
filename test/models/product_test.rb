# frozen_string_literal: true

require 'test_helper'

class ProductTest < ActiveSupport::TestCase
  test 'delete associated notification' do
    user = users(:kimura)
    practice = practices(:practice_5)
    product = Product.create!(practice: practice, user: user, body: 'test')
    product.destroy
    assert_not Notification.where(path: "/products/#{product.id}").exists?
  end

  test 'adviser watches trainee product when trainee create product' do
    trainee = users(:kensyu)
    adviser = users(:senpai)
    practice = practices(:practice_2)
    product = Product.new(
      body: 'test',
      user: trainee,
      practice: practice
    )
    product.save!
    assert_not_nil Watch.find_by(user: adviser, watchable: product)
  end

  test 'adviser watches trainee product when trainee remove wip of product' do
    trainee = users(:kensyu)
    adviser = users(:senpai)
    practice = practices(:practice_2)
    product = Product.new(
      body: 'test',
      user: trainee,
      practice: practice,
      wip: true
    )
    product.save!
    assert_nil product.published_at

    product.wip = false
    product.save!

    assert_not_nil Watch.find_by(user: adviser, watchable: product)
    assert_not_nil product.published_at
  end

  test '#change_learning_status' do
    user = users(:kimura)
    practice = practices(:practice_5)
    product = Product.create!(
      body: 'test',
      user: user,
      practice: practice
    )
    assert Learning.find_by(user: user, practice: practice, status: :submitted)

    status = :complete
    product.change_learning_status(status)
    assert Learning.find_by(user: user, practice: practice, status: :complete)
  end

  test "#category" do
    product = products(:product_1)
    course = courses(:course_1)
    category = categories(:category_2)

    assert_equal category, product.category(course)
  end
end
