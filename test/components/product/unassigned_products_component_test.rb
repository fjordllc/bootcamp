# frozen_string_literal: true

require 'test_helper'
require 'supports/decorator_helper'

class Products::UnassignedProductsComponentTest < ViewComponent::TestCase
  include DecoratorHelper

  def setup
    auto_decorate(User)
    @current_user = users(:komagata)
    @is_mentor = true
    @reply_warning_days = 4
  end

  def test_default
    products = [products(:product1), products(:product2), products(:product3),
                products(:product4), products(:product5), products(:product6),
                products(:product7), products(:product8), products(:product9)]
    products_grouped_by_elapsed_days = group_by_elapsed_days(products)
    render_inline(Products::UnassignedProductsComponent.new(
                    products:,
                    products_grouped_by_elapsed_days:,
                    is_mentor: @is_mentor,
                    current_user_id: @current_user.id,
                    reply_warning_days: @reply_warning_days
                  ))
    assert_selector '.is-reply-deadline#6days-elapsed', text: '6日以上経過（3）'
    assert_selector '.is-reply-alert#5days-elapsed', text: '5日経過（1）'
    assert_selector '.is-reply-warning#4days-elapsed', text: '4日経過（1）'
  end

  def test_any_products
    products = []
    products_grouped_by_elapsed_days = {}
    render_inline(Products::UnassignedProductsComponent.new(
                    products:,
                    products_grouped_by_elapsed_days:,
                    is_mentor: @is_mentor,
                    current_user_id: @current_user.id,
                    reply_warning_days: @reply_warning_days
                  ))
    assert_text 'しばらく4日経過に到達する提出物はありません。'
  end

  def test_any_products_elapsed_reply_warning_days
    products_within_reply_warning_days = [products(:product2), products(:product3), products(:product4)]
    products_grouped_by_elapsed_days = group_by_elapsed_days(products_within_reply_warning_days)
    render_inline(Products::UnassignedProductsComponent.new(
                    products: products_within_reply_warning_days,
                    products_grouped_by_elapsed_days:,
                    is_mentor: @is_mentor,
                    current_user_id: @current_user.id,
                    reply_warning_days: @reply_warning_days
                  ))
    assert_text 'しばらく4日経過に到達する提出物はありません。'
  end

  def any_products_almost_passed_reply_warning_days
    products_passed_reply_warning_days = [products(:product5), products(:product6), products(:product7)]
    products_grouped_by_elapsed_days = group_by_elapsed_days(products_passed_reply_warning_days)
    render_inline(Products::UnassignedProductsComponent.new(
                    products: products_passed_reply_warning_days,
                    products_grouped_by_elapsed_days:,
                    is_mentor: @is_mentor,
                    current_user_id: @current_user.id,
                    reply_warning_days: @reply_warning_days
                  ))
    assert_text 'しばらく4日経過に到達する提出物はありません。'
  end

  def test_products_almost_passed_reply_warning_days
    products_passed_reply_warning_days = [products(:product5)]
    products_almost_passed_reply_warning_days = [products(:product70), products(:product71)]
    products = products_passed_reply_warning_days + products_almost_passed_reply_warning_days
    products_grouped_by_elapsed_days = group_by_elapsed_days(products)
    render_inline(Products::UnassignedProductsComponent.new(
                    products:,
                    products_grouped_by_elapsed_days:,
                    is_mentor: @is_mentor,
                    current_user_id: @current_user.id,
                    reply_warning_days: @reply_warning_days
                  ))
    assert_text '2件の提出物が、8時間以内に4日経過に到達します。'
  end

  private

  def group_by_elapsed_days(products)
    reply_deadline_days = @reply_warning_days + 2
    products.group_by { |product| product.elapsed_days >= reply_deadline_days ? reply_deadline_days : product.elapsed_days }
  end
end
