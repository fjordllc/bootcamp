# frozen_string_literal: true

require 'test_helper'

class Products::UserProductsComponentTest < ViewComponent::TestCase
  test 'displays user products when products exist' do
    user = users(:komagata)
    current_user = users(:machida)
    products = user.products.not_wip.includes(:practice, :user, :comments, :checks)

    render_inline(Products::UserProductsComponent.new(
                    products:,
                    current_user:,
                    is_mentor: true
                  ))

    assert_selector '.card-list.a-card'
    assert_selector '.card-header__title', text: '提出物'

    if products.any?
      assert_selector '.card-list__items'
    else
      assert_selector '.o-empty-message'
    end
  end

  test 'displays empty message when no products exist' do
    current_user = users(:machida)
    empty_products = Product.none

    render_inline(Products::UserProductsComponent.new(
                    products: empty_products,
                    current_user:,
                    is_mentor: true
                  ))

    assert_selector '.card-list.a-card'
    assert_selector '.card-header__title', text: '提出物'
    assert_selector '.o-empty-message'
    assert_selector '.o-empty-message__text', text: '提出物はまだありません。'
  end
end
