# frozen_string_literal: true

require 'test_helper'

class PracticeProgressMigratorTest < ActiveSupport::TestCase
  def setup
    @user = users(:kimura)
    # Clear all data to ensure test isolation
    @user.learnings.destroy_all
    @user.products.destroy_all
    @migrator = PracticeProgressMigrator.new(@user)
    @rails_course = courses(:course1) # Railsエンジニアコース
  end

  test 'migrate copies learning and product successfully' do
    # Setup original practice
    original_practice = practices(:practice1)
    original_practice.categories.first.courses << @rails_course unless original_practice.categories.first.courses.include?(@rails_course)

    # Setup copied practice
    copied_practice = Practice.new(
      title: "#{original_practice.title} (Reスキル) #{Time.current.to_i}",
      description: original_practice.description,
      goal: original_practice.goal,
      source_id: original_practice.id
    )
    copied_practice.categories << original_practice.categories.first
    copied_practice.save!

    # Create original learning and product
    Learning.create!(
      user: @user,
      practice: original_practice,
      status: 'complete'
    )

    original_product = Product.create!(
      user: @user,
      practice: original_practice,
      body: 'Original submission'
    )

    # Create check for original product
    Check.create!(
      user: users(:komagata),
      checkable: original_product
    )

    result = @migrator.migrate(original_practice.id)

    assert result

    # Verify learning was copied
    copied_learning = Learning.find_by(user: @user, practice: copied_practice)
    assert_not_nil copied_learning
    assert_equal 'complete', copied_learning.status

    # Verify product was copied
    copied_product = Product.find_by(user: @user, practice: copied_practice)
    assert_not_nil copied_product
    assert_equal 'Original submission', copied_product.body

    # Verify check was copied
    copied_check = Check.find_by(checkable: copied_product)
    assert_not_nil copied_check
    assert_equal users(:komagata).id, copied_check.user_id
  end

  test 'migrate returns error when copied practice not found' do
    practice = practices(:practice1)

    result = @migrator.migrate(practice.id)

    assert_not result
  end

  test 'migrate preserves existing learning and product' do
    # Setup original practice
    original_practice = practices(:practice1)
    original_practice.categories.first.courses << @rails_course unless original_practice.categories.first.courses.include?(@rails_course)

    # Setup copied practice
    copied_practice = Practice.new(
      title: "#{original_practice.title} (Reスキル) #{Time.current.to_i}",
      description: original_practice.description,
      goal: original_practice.goal,
      source_id: original_practice.id
    )
    copied_practice.categories << original_practice.categories.first
    copied_practice.save!

    # Create original learning and product
    Learning.create!(
      user: @user,
      practice: original_practice,
      status: 'complete'
    )

    Product.create!(
      user: @user,
      practice: original_practice,
      body: 'Updated submission'
    )

    # Create existing learning and product for copied practice
    existing_learning = Learning.create!(
      user: @user,
      practice: copied_practice,
      status: 'started'
    )

    existing_product = Product.create!(
      user: @user,
      practice: copied_practice,
      body: 'Old submission'
    )

    result = @migrator.migrate(original_practice.id)

    assert result

    # Verify learning was NOT updated (preserved existing state)
    existing_learning.reload
    assert_equal 'started', existing_learning.status

    # Verify product was NOT updated (preserved existing state)
    existing_product.reload
    assert_equal 'Old submission', existing_product.body
  end

  test 'migrate_all copies all completed practices' do
    # Setup original practices
    original_practice1 = practices(:practice1)
    original_practice1.categories.first.courses << @rails_course unless original_practice1.categories.first.courses.include?(@rails_course)

    original_practice2 = practices(:practice2)
    original_practice2.categories.first.courses << @rails_course unless original_practice2.categories.first.courses.include?(@rails_course)

    # Setup copied practices
    copied_practice1 = Practice.new(
      title: "#{original_practice1.title} (Reスキル) #{Time.current.to_i}",
      description: original_practice1.description,
      goal: original_practice1.goal,
      source_id: original_practice1.id
    )
    copied_practice1.categories << original_practice1.categories.first
    copied_practice1.save!

    copied_practice2 = Practice.new(
      title: "#{original_practice2.title} (Reスキル) #{Time.current.to_i + 1}",
      description: original_practice2.description,
      goal: original_practice2.goal,
      source_id: original_practice2.id
    )
    copied_practice2.categories << original_practice2.categories.first
    copied_practice2.save!

    # Create original learnings and products
    Learning.create!(user: @user, practice: original_practice1, status: 'complete')
    Learning.create!(user: @user, practice: original_practice2, status: 'complete')

    Product.create!(user: @user, practice: original_practice1, body: 'Submission 1')
    Product.create!(user: @user, practice: original_practice2, body: 'Submission 2')

    result = @migrator.migrate_all

    assert result

    # Verify both learnings were copied
    copied_learning1 = Learning.find_by(user: @user, practice: copied_practice1)
    copied_learning2 = Learning.find_by(user: @user, practice: copied_practice2)
    assert_not_nil copied_learning1
    assert_not_nil copied_learning2
    assert_equal 'complete', copied_learning1.status
    assert_equal 'complete', copied_learning2.status

    # Verify both products were copied
    copied_product1 = Product.find_by(user: @user, practice: copied_practice1)
    copied_product2 = Product.find_by(user: @user, practice: copied_practice2)
    assert_not_nil copied_product1
    assert_not_nil copied_product2
    assert_equal 'Submission 1', copied_product1.body
    assert_equal 'Submission 2', copied_product2.body
  end

  test 'migrate_all skips practices without copied version' do
    # Setup original practice without copied version
    original_practice = practices(:practice1)
    original_practice.categories.first.courses << @rails_course unless original_practice.categories.first.courses.include?(@rails_course)

    # Create original learning and product
    Learning.create!(user: @user, practice: original_practice, status: 'complete')
    Product.create!(user: @user, practice: original_practice, body: 'Submission')

    result = @migrator.migrate_all

    assert result
  end
end
