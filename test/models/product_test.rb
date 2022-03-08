# frozen_string_literal: true

require 'test_helper'

class ProductTest < ActiveSupport::TestCase
  test 'delete associated notification' do
    user = users(:kimura)
    practice = practices(:practice5)
    product = Product.create!(practice: practice, user: user, body: 'test')
    product.destroy
    assert_not Notification.where(link: "/products/#{product.id}").exists?
  end

  test 'adviser watches trainee product when trainee create product' do
    trainee = users(:kensyu)
    adviser = users(:senpai)
    practice = practices(:practice2)
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
    practice = practices(:practice2)
    product = Product.new(
      body: 'test',
      user: trainee,
      practice: practice,
      wip: true
    )
    product.save!

    assert_nil Watch.find_by(user: adviser, watchable: product)

    product.wip = false
    product.save!

    assert_not_nil Watch.find_by(user: adviser, watchable: product)
  end

  test '#change_learning_status' do
    user = users(:kimura)
    practice = practices(:practice5)
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

  test '#category' do
    product = products(:product1)
    course = courses(:course1)
    category = categories(:category2)

    assert_equal category, product.category(course)
  end

  test 'other_checker_exists' do
    checker = users(:komagata)
    current_user = users(:machida)
    product = Product.create!(
      body: 'test',
      user: users(:kimura),
      practice: practices(:practice5),
      checker_id: checker.id
    )
    assert product.other_checker_exists?(current_user.id)
  end

  test 'other_checker_not_exists' do
    current_user = users(:machida)
    product = Product.create!(
      body: 'test',
      user: users(:kimura),
      practice: practices(:practice5),
      checker_id: nil
    )
    assert_not product.other_checker_exists?(current_user.id)
  end

  test '#checker_name' do
    checker = users(:komagata)
    product = Product.create!(
      body: 'test',
      user: users(:kimura),
      practice: practices(:practice5),
      checker_id: checker.id
    )
    assert_equal 'komagata', product.checker_name
  end

  test '#save_checker' do
    current_user = users(:komagata)
    product = Product.create!(
      body: 'test',
      user: users(:kimura),
      practice: practices(:practice5),
      checker_id: nil
    )
    assert product.save_checker(current_user.id)
  end

  test '.self_assigned_no_replied_products' do
    current_user = users(:mentormentaro)
    product = Product.create!(
      body: 'test',
      user: users(:kimura),
      practice: practices(:practice5),
      checker_id: nil
    )
    product.save_checker(current_user.id)
    assert_equal [product.id], Product.self_assigned_no_replied_products(current_user.id).pluck(:id)
  end
end
