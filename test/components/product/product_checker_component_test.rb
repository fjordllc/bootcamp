# frozen_string_literal: true

require 'test_helper'
require 'supports/decorator_helper'

class Products::ProductCheckerComponentTest < ViewComponent::TestCase
  include DecoratorHelper

  def setup
    auto_decorate(User)
    @current_user = users(:komagata)
  end

  def test_render_assign_button_when_product_is_unassigned
    unassigned__product = products(:product6)

    render_inline(Products::ProductCheckerComponent.new(
                    checker_id: nil,
                    checker_name: nil,
                    current_user_id: @current_user.id,
                    product_id: unassigned__product.id,
                    checker_avatar: nil
                  ))

    assert_selector 'button#check-product-button.is-secondary'
    assert_text '担当する'
  end

  def test_render_unassign_button_when_product_is_assigned_by_current_user
    assigned_product = products(:product2)

    render_inline(Products::ProductCheckerComponent.new(
                    checker_id: assigned_product.checker_id,
                    checker_name: assigned_product.checker_name,
                    current_user_id: @current_user.id,
                    product_id: assigned_product.id,
                    checker_avatar: assigned_product.checker_avatar
                  ))

    assert_selector 'button#check-product-button.is-warning'
    assert_text '担当から外れる'
  end
end
