# frozen_string_literal: true

class CopyProduct
  include Interactor

  def call
    validate_inputs
    return if context.failure?

    find_original_product
    return unless context.original_product

    check_existing_product
    return if existing_product_found?

    create_copied_product
  end

  private

  def validate_inputs
    return if context.user && context.from_practice && context.to_practice

    context.fail!(error: 'Missing required parameters: user, from_practice, to_practice')
  end

  def find_original_product
    context.original_product = Product.find_by(
      user: context.user,
      practice: context.from_practice
    )

    return if context.original_product

    # Set message but don't fail - let the Organizer continue
    context.message = 'Product not found – skipping copy'
  end

  def check_existing_product
    context.existing_product = Product.find_by(
      user: context.user,
      practice: context.to_practice
    )
  end

  def existing_product_found?
    if context.existing_product
      # Set both existing and original products in context for subsequent interactors
      context.copied_product = context.existing_product
      context.message = 'Product already exists, skipping copy'
      true
    else
      false
    end
  end

  def create_copied_product
    context.copied_product = Product.create!(
      user: context.user,
      practice: context.to_practice,
      body: context.original_product.body,
      wip: context.original_product.wip
    )

    # original_product is already set in context from find_original_product
    context.message = 'Product copied successfully'
  rescue ActiveRecord::RecordInvalid => e
    context.fail!(error: "Failed to create product: #{e.message}")
  end
end
