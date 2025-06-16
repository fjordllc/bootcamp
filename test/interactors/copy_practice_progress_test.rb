# frozen_string_literal: true

require 'test_helper'

class CopyPracticeProgressTest < ActiveSupport::TestCase
  def setup
    @user = users(:kimura)
    @mentor = users(:komagata)
    @from_practice = practices(:practice1)
    @to_practice = practices(:practice2)

    # Clear any existing data
    @user.learnings.destroy_all
    @user.products.destroy_all
    Check.joins(:checkable)
         .where(checkable: { user_id: @user.id, practice_id: @from_practice.id })
         .destroy_all
  end

  test 'successfully copies learning, product, and checks when everything exists' do
    # Create original data
    Learning.create!(user: @user, practice: @from_practice, status: 'complete')
    original_product = Product.create!(
      user: @user,
      practice: @from_practice,
      body: 'Original submission',
      wip: false
    )
    Check.create!(user: @mentor, checkable: original_product)

    result = CopyPracticeProgress.call(
      user: @user,
      from_practice: @from_practice,
      to_practice: @to_practice
    )

    assert result.success?
    assert_equal 'Learning, product, and checks copied successfully', result.message

    # Verify learning was copied
    copied_learning = Learning.find_by(user: @user, practice: @to_practice)
    assert_not_nil copied_learning
    assert_equal 'complete', copied_learning.status

    # Verify product was copied
    copied_product = Product.find_by(user: @user, practice: @to_practice)
    assert_not_nil copied_product
    assert_equal 'Original submission', copied_product.body

    # Verify check was copied
    copied_check = Check.find_by(checkable: copied_product, user: @mentor)
    assert_not_nil copied_check
  end

  test 'successfully copies only learning when no product exists' do
    # Create only learning data
    Learning.create!(user: @user, practice: @from_practice, status: 'complete')

    result = CopyPracticeProgress.call(
      user: @user,
      from_practice: @from_practice,
      to_practice: @to_practice
    )

    assert result.success?

    # Verify learning was copied
    copied_learning = Learning.find_by(user: @user, practice: @to_practice)
    assert_not_nil copied_learning
    assert_equal 'complete', copied_learning.status

    # Verify no product was copied
    copied_product = Product.find_by(user: @user, practice: @to_practice)
    assert_nil copied_product
  end

  test 'skips copying when target data already exists' do
    # Create original data
    Learning.create!(user: @user, practice: @from_practice, status: 'complete')
    Product.create!(user: @user, practice: @from_practice, body: 'Original submission')

    # Create existing target data
    Learning.create!(user: @user, practice: @to_practice, status: 'started')
    Product.create!(user: @user, practice: @to_practice, body: 'Existing submission')

    result = CopyPracticeProgress.call(
      user: @user,
      from_practice: @from_practice,
      to_practice: @to_practice
    )

    assert result.success?

    # Verify existing data was not modified
    copied_learning = Learning.find_by(user: @user, practice: @to_practice)
    assert_equal 'started', copied_learning.status

    copied_product = Product.find_by(user: @user, practice: @to_practice)
    assert_equal 'Existing submission', copied_product.body
  end

  test 'fails when no original learning exists' do
    result = CopyPracticeProgress.call(
      user: @user,
      from_practice: @from_practice,
      to_practice: @to_practice
    )

    assert_not result.success?
    assert_equal 'Original learning not found', result.error
  end

  test 'fails when required parameters are missing' do
    result = CopyPracticeProgress.call(
      user: nil,
      from_practice: @from_practice,
      to_practice: @to_practice
    )

    assert_not result.success?
    assert_equal 'Missing required parameters: user, from_practice, to_practice', result.error
  end
end
