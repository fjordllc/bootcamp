# frozen_string_literal: true

class Products::UserProductsComponent < ViewComponent::Base
  def initialize(products:, current_user:, is_mentor:)
    @products = products
    @current_user = current_user
    @is_mentor = is_mentor
  end

  private

  attr_reader :products, :current_user, :is_mentor

  def products?
    products.present?
  end

  def product_component_params(product)
    {
      product:,
      is_mentor:,
      is_admin: current_user.admin?,
      current_user_id: current_user.id,
      reply_deadline_days: 7, # Default value from existing implementation
      display_until_next_elapsed_days: false,
      display_user_icon: false
    }
  end
end
