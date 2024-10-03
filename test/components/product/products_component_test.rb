# frozen_string_literal: true

require 'test_helper'
require 'supports/decorator_helper'

class Products::ProductsComponentTest < ViewComponent::TestCase
  def setup
    DecoratorHelper.auto_decorate(User)
    @current_user = users(:komagata)
    @is_mentor = true
  end

  def test_default
    products = [products(:product6), products(:product7), products(:product8), products(:product9), products(:product10)]
    products_grouped_by_elapsed_days = group_by_elapsed_days(products)
    render_inline(Products::ProductsComponent.new(products:,
                                                  products_grouped_by_elapsed_days:,
                                                  is_mentor: @is_mentor,
                                                  current_user_id: @current_user.id))
    assert_selector '.card-header.a-elapsed-days.is-reply-deadline#7days-elapsed', text: '7日以上経過（3）'
    assert_selector '.card-header.a-elapsed-days.is-reply-alert#6days-elapsed', text: '6日経過（1）'
    assert_selector '.card-header.a-elapsed-days.is-reply-warning#5days-elapsed', text: '5日経過（1）'
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
    products_grouped_by_elapsed_days = group_by_elapsed_days(products_within_5days)
    render_inline(Products::ProductsComponent.new(products: products_within_5days,
                                                  products_grouped_by_elapsed_days:,
                                                  is_mentor: @is_mentor,
                                                  current_user_id: @current_user.id))
    assert_text '5日経過した提出物はありません'
  end

  def any_products_almost_passed_5days
    products_passed_5days = [products(:product6), products(:product7), products(:product8)]
    products_grouped_by_elapsed_days = group_by_elapsed_days(products_passed_5days)
    render_inline(Products::ProductsComponent.new(products: products_passed_5days,
                                                  products_grouped_by_elapsed_days:,
                                                  is_mentor: @is_mentor,
                                                  current_user_id: @current_user.id))
    assert_text 'しばらく5日経過に到達する提出物はありません。'
  end

  def test_products_almost_passed_5days
    products_passed_5days = [products(:product6)]
    products_almost_passed_5days = [products(:product70), products(:product71)]
    products = products_passed_5days + products_almost_passed_5days
    products_grouped_by_elapsed_days = group_by_elapsed_days(products)
    render_inline(Products::ProductsComponent.new(products:,
                                                  products_grouped_by_elapsed_days:,
                                                  is_mentor: @is_mentor,
                                                  current_user_id: @current_user.id))
    assert_text '2件の提出物が、8時間以内に5日経過に到達します。'
  end

  private

  def group_by_elapsed_days(products)
    products.group_by { |product| product.elapsed_days >= 7 ? 7 : product.elapsed_days }
  end
end
