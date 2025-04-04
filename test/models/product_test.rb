# frozen_string_literal: true

require 'test_helper'

class ProductTest < ActiveSupport::TestCase
  test 'delete associated notification' do
    user = users(:kimura)
    practice = practices(:practice5)
    product = Product.create!(practice:, user:, body: 'test')
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
      practice:
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
      practice:,
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
      user:,
      practice:
    )

    status = :started
    product.change_learning_status(status)
    assert Learning.find_by(user:, practice:, status: :started)
  end

  test '#category' do
    product = products(:product1)
    course = courses(:course1)
    category = categories(:category2)

    assert_equal category, product.category(course)
  end

  test '#other_checker_exists' do
    checker = users(:komagata)
    other_checker = users(:machida)
    product = Product.create!(
      body: 'test',
      user: users(:kimura),
      practice: practices(:practice5),
      checker_id: checker.id
    )
    assert product.other_checker_exists?(other_checker.id)
  end

  test '#other_checker_exists return false when other checker not exists' do
    other_checker = users(:machida)
    product = Product.create!(
      body: 'test',
      user: users(:kimura),
      practice: practices(:practice5),
      checker_id: nil
    )
    assert_not product.other_checker_exists?(other_checker.id)
  end

  test '#other_checker_exists return false when checker is oneself' do
    other_checker = users(:machida)
    product = Product.create!(
      body: 'test',
      user: users(:kimura),
      practice: practices(:practice5),
      checker_id: other_checker.id
    )
    assert_not product.other_checker_exists?(other_checker.id)
  end

  test '#checker_name' do
    product = products(:product1)

    product.update!(checker: nil)
    assert_nil product.checker_name

    product.update!(checker: users(:mentormentaro))
    assert_equal 'mentormentaro', product.checker_name
  end

  test '#checker_avatar' do
    product = products(:product1)

    product.update!(checker: nil)
    assert_nil product.checker_avatar

    product.update!(checker: users(:mentormentaro))
    assert_not_nil product.checker_avatar
  end

  test '#save_checker' do
    checker = users(:komagata)
    product = Product.create!(
      body: 'test',
      user: users(:kimura),
      practice: practices(:practice5),
      checker_id: nil
    )
    assert product.save_checker(checker.id)
  end

  test '.self_assigned_no_replied_products' do
    mentor = users(:mentormentaro)
    no_replied_product = Product.create!(
      body: 'test',
      user: users(:kimura),
      practice: practices(:practice5),
      checker_id: mentor.id,
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
      checker_id: mentor.id,
      published_at: Time.current.to_formatted_s(:db),
      wip: true
    )

    product_id_list = Product.self_assigned_no_replied_products(mentor.id).pluck(:id)
    assert_not_includes product_id_list, no_replied_wip_product.id
  end

  test '#notification_type' do
    product = Product.create!(
      body: 'first saved as WIP',
      user: users(:kimura),
      practice: practices(:practice5),
      checker_id: nil,
      wip: true
    )

    product.update!(body: 'product is submitted.', wip: false, published_at: Time.current)
    assert_equal :submitted, product.notification_type

    product.update!(body: 'product is saved as WIP after submission.', wip: true)

    product.update!(body: 'product is updated.', wip: false, published_at: Time.current)
    assert_equal :product_update, product.notification_type
  end

  test '#updated_after_submission?' do
    product = Product.create!(
      body: 'product is submitted.',
      user: users(:kimura),
      practice: practices(:practice5),
      checker_id: nil
    )
    assert_not product.updated_after_submission?
    product.update!(body: 'product is updated.')
    assert product.updated_after_submission?

    wip_product = Product.create!(
      body: 'first saved as wip.',
      user: users(:kimura),
      practice: practices(:practice7),
      checker_id: nil,
      wip: true
    )
    wip_product.update!(body: 'product is updated.', wip: false, published_at: Time.current)
    assert_not wip_product.updated_after_submission?
  end

  test '.unhibernated_user_products' do
    hiberanated_user = users(:kyuukai)

    hibernated_user_product = Product.create!(
      body: "hibernated user's product.",
      user: hiberanated_user,
      practice: practices(:practice7),
      checker_id: nil
    )

    assert_includes Product.all, hibernated_user_product
    assert_not_includes Product.unhibernated_user_products, hibernated_user_product
  end

  test '.require_assignment_products' do
    require_assignment_product = products(:product6)
    assigned_product = products(:product68)
    checked_product = products(:product2)
    wip_product = products(:product5)
    require_assignment_product_id_list = Product.require_assignment_products.pluck(:id)

    assert_includes require_assignment_product_id_list, require_assignment_product.id
    assert_not_includes require_assignment_product_id_list, assigned_product.id
    assert_not_includes require_assignment_product_id_list, checked_product.id
    assert_not_includes require_assignment_product_id_list, wip_product.id
  end

  test '.group_by_elapsed_days' do
    zero_day_elapsed_products = [products(:product1)]
    one_day_elapsed_products = [products(:product2)]
    two_days_elapsed_products = [products(:product3)]
    three_days_elapsed_products = [products(:product4)]
    four_days_elapsed_products = [products(:product5)]
    five_days_elapsed_products = [products(:product6)]
    over_six_days_elapsed_products = [products(:product7), products(:product8), products(:product9)]
    products = zero_day_elapsed_products + one_day_elapsed_products +
               two_days_elapsed_products + three_days_elapsed_products +
               four_days_elapsed_products + five_days_elapsed_products +
               over_six_days_elapsed_products
    products_grouped_by_elapsed_days = Product.group_by_elapsed_days(products)

    assert_equal 7, products_grouped_by_elapsed_days.size
    assert_equal zero_day_elapsed_products, products_grouped_by_elapsed_days[0]
    assert_equal one_day_elapsed_products, products_grouped_by_elapsed_days[1]
    assert_equal two_days_elapsed_products, products_grouped_by_elapsed_days[2]
    assert_equal three_days_elapsed_products, products_grouped_by_elapsed_days[3]
    assert_equal four_days_elapsed_products, products_grouped_by_elapsed_days[4]
    assert_equal five_days_elapsed_products, products_grouped_by_elapsed_days[5]
    assert_equal over_six_days_elapsed_products, products_grouped_by_elapsed_days[6]
  end
end
