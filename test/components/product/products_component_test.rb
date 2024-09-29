# frozen_string_literal: true

require 'test_helper'

class Products::ProductsComponentTest < ViewComponent::TestCase
  def setup
    @current_user = users(:komagata).extend(UserDecorator)
    @is_mentor = true
  end

  def test_any_products
    products = []
    products_grouped_by_elapsed_days = {}
    render_inline(Products::ProductsComponent.new(products:,
                                                  products_grouped_by_elapsed_days:,
                                                  is_mentor: @is_mentor,
                                                  current_user_id: @current_user.id))
    assert_text '提出物はありません'
  end

  def test_any_products_5days_elapsed
    products_within_5days = [products(:product2), products(:product3), products(:product4), products(:product5)]
    products_grouped_by_elapsed_days = products_within_5days.group_by { |product| product.elapsed_days >= 7 ? 7 : product.elapsed_days }
    render_inline(Products::ProductsComponent.new(products: products_within_5days,
                                                  products_grouped_by_elapsed_days:,
                                                  is_mentor: @is_mentor,
                                                  current_user_id: @current_user.id))
    assert_text '5日経過した提出物はありません'
  end
end
