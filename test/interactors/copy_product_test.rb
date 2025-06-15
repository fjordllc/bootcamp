# frozen_string_literal: true

require 'test_helper'

class CopyProductTest < ActiveSupport::TestCase
  def setup
    @user = users(:kimura)
    @from_practice = practices(:practice1)
    @to_practice = practices(:practice2)

    # Clear any existing data
    @user.products.destroy_all
  end

  test 'successfully copies product when original exists and target does not' do
    # Create original product
    Product.create!(
      user: @user,
      practice: @from_practice,
      body: 'Original submission',
      wip: false
    )

    result = CopyProduct.call(
      user: @user,
      from_practice: @from_practice,
      to_practice: @to_practice
    )

    assert result.success?
    assert_equal 'Product copied successfully', result.message
    assert_not_nil result.copied_product

    # Verify the copied product was created
    copied_product = Product.find_by(user: @user, practice: @to_practice)
    assert_not_nil copied_product
    assert_equal 'Original submission', copied_product.body
    assert_not copied_product.wip
  end

  test 'skips copy when target product already exists' do
    # Create both original and target products
    Product.create!(user: @user, practice: @from_practice, body: 'Original submission', wip: false)
    existing_product = Product.create!(user: @user, practice: @to_practice, body: 'Existing submission', wip: true)

    result = CopyProduct.call(
      user: @user,
      from_practice: @from_practice,
      to_practice: @to_practice
    )

    assert result.success?
    assert_equal 'Product already exists, skipping copy', result.message
    assert_equal existing_product, result.existing_product

    # Verify the existing product was not modified
    existing_product.reload
    assert_equal 'Existing submission', existing_product.body
    assert existing_product.wip
  end

  test 'succeeds with message when original product does not exist' do
    result = CopyProduct.call(
      user: @user,
      from_practice: @from_practice,
      to_practice: @to_practice
    )

    assert result.success?
    assert_equal 'Learning copied successfully (no product to copy)', result.message
  end

  test 'fails when required parameters are missing' do
    result = CopyProduct.call(
      user: nil,
      from_practice: @from_practice,
      to_practice: @to_practice
    )

    assert_not result.success?
    assert_equal 'Missing required parameters: user, from_practice, to_practice', result.error
  end

  test 'fails when product creation fails' do
    # Create original product
    Product.create!(user: @user, practice: @from_practice, body: 'Original submission', wip: false)

    # Mock Product.create! to raise an exception
    Product.stub :create!, ->(*) { raise ActiveRecord::RecordInvalid, Product.new } do
      result = CopyProduct.call(
        user: @user,
        from_practice: @from_practice,
        to_practice: @to_practice
      )

      assert_not result.success?
      assert_match(/Failed to create product/, result.error)
    end
  end
end
