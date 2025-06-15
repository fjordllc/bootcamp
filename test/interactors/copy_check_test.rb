# frozen_string_literal: true

require 'test_helper'

class CopyCheckTest < ActiveSupport::TestCase
  def setup
    @user1 = users(:kimura)
    @user2 = users(:komagata)
    @from_practice = practices(:practice1)
    @to_practice = practices(:practice2)

    # Clear any existing data
    Check.where(checkable_type: 'Product').destroy_all
    Product.destroy_all

    # Create products
    @original_product = Product.create!(
      user: @user1,
      practice: @from_practice,
      body: 'Original submission'
    )

    @copied_product = Product.create!(
      user: @user1,
      practice: @to_practice,
      body: 'Copied submission'
    )
  end

  test 'successfully copies checks when original has checks and target has none' do
    # Create checks for original product
    Check.create!(user: @user1, checkable: @original_product)
    Check.create!(user: @user2, checkable: @original_product)

    result = CopyCheck.call(
      original_product: @original_product,
      copied_product: @copied_product
    )

    assert result.success?
    assert_equal 'Learning, product, and checks copied successfully', result.message
    assert_equal 2, result.copied_checks_count
    assert_equal 0, result.skipped_checks_count

    # Verify the checks were copied
    copied_checks = Check.where(checkable: @copied_product)
    assert_equal 2, copied_checks.count
    assert_includes copied_checks.pluck(:user_id), @user1.id
    assert_includes copied_checks.pluck(:user_id), @user2.id
  end

  test 'skips existing checks and only copies new ones' do
    # Create checks for original product
    Check.create!(user: @user1, checkable: @original_product)
    Check.create!(user: @user2, checkable: @original_product)

    # Create one existing check for copied product
    Check.create!(user: @user1, checkable: @copied_product)

    result = CopyCheck.call(
      original_product: @original_product,
      copied_product: @copied_product
    )

    assert result.success?
    assert_equal 'Learning, product, and checks copied successfully', result.message
    assert_equal 1, result.copied_checks_count
    assert_equal 1, result.skipped_checks_count

    # Verify only one new check was added
    copied_checks = Check.where(checkable: @copied_product)
    assert_equal 2, copied_checks.count
  end

  test 'succeeds when original product has no checks' do
    result = CopyCheck.call(
      original_product: @original_product,
      copied_product: @copied_product
    )

    assert result.success?
    assert_equal 'No checks found to copy', result.message

    # Verify no checks were created
    copied_checks = Check.where(checkable: @copied_product)
    assert_equal 0, copied_checks.count
  end

  test 'skips when required parameters are missing' do
    result = CopyCheck.call(
      original_product: nil,
      copied_product: @copied_product
    )

    # Should succeed but skip execution due to missing original_product
    assert result.success?
    assert_equal 'No product available for check copying, skipping', result.message

    # Verify no checks were created
    copied_checks = Check.where(checkable: @copied_product)
    assert_equal 0, copied_checks.count
  end

  test 'fails when check creation fails' do
    # Create check for original product
    Check.create!(user: @user1, checkable: @original_product)

    # Mock Check.create! to raise an exception
    Check.stub :create!, ->(*) { raise ActiveRecord::RecordInvalid, Check.new } do
      result = CopyCheck.call(
        original_product: @original_product,
        copied_product: @copied_product
      )

      assert_not result.success?
      assert_match(/Failed to create check/, result.error)
    end
  end
end
