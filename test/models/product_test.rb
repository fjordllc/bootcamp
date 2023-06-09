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
    practice = practices(:practice3)
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
    practice = practices(:practice3)
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
    other_checker = users(:machida)
    product = Product.create!(
      body: 'test',
      user: users(:kimura),
      practice: practices(:practice5),
      checker: checker
    )
    assert product.other_checker_exists?(other_checker.id)
  end

  test 'other_checker_not_exists' do
    other_checker = users(:machida)
    product = Product.create!(
      body: 'test',
      user: users(:kimura),
      practice: practices(:practice5),
      checker: nil
    )
    assert_not product.other_checker_exists?(other_checker.id)
  end

  test '#checker_name' do
    checker = users(:komagata)
    product = Product.create!(
      body: 'test',
      user: users(:kimura),
      practice: practices(:practice5),
      checker: checker
    )
    assert_equal 'komagata', product.checker_name
  end

  test '#save_checker' do
    checker = users(:komagata)
    product = Product.create!(
      body: 'test',
      user: users(:kimura),
      practice: practices(:practice5),
      checker: nil
    )
    assert product.save_checker(checker.id)
  end

  test '.self_assigned_no_replied_products' do
    mentor = users(:mentormentaro)
    no_replied_product = Product.create!(
      body: 'test',
      user: users(:kimura),
      practice: practices(:practice5),
      checker: mentor,
      published_at: Time.current.to_formatted_s(:db)
    )

    product_id_list = Product.self_assigned_no_replied_products(mentor.id).pluck(:id)
    assert_includes product_id_list, no_replied_product.id
  end

  test '.self_assigned_no_replied_products not include wip products' do
    mentor = users(:mentormentaro)
    no_replied_wip_product = Product.create!(
      body: 'test',
      user: users(:kimura),
      practice: practices(:practice5),
      checker: mentor,
      published_at: Time.current.to_formatted_s(:db),
      wip: true
    )

    product_id_list = Product.self_assigned_no_replied_products(mentor.id).pluck(:id)
    assert_not_includes product_id_list, no_replied_wip_product.id
  end
end
