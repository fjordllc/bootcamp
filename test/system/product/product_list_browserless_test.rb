# frozen_string_literal: true

require 'browserless_system_test_case'

class Product::ProductListBrowserlessTest < BrowserlessSystemTestCase
  test 'display WIP badge on WIP product' do
    product = products(:product5)
    assert product.wip?

    visit_with_auth '/products?page=2', 'komagata'
    within '.card-list-item.is-wip' do
      assert_selector '.a-list-item-badge.is-wip', text: 'WIP'
    end
  end

  test 'display comment count and commenters on product with comments' do
    product = products(:product1)
    assert product.comments.size.positive?

    visit_with_auth '/products', 'komagata'
    product_item = find("a[href='/products/#{product.id}']").ancestor('.card-list-item')
    within product_item do
      assert_text(/コメント（\s*#{product.comments.size}\s*）/)
      assert_selector '.card-list-item__user-icons'
    end
  end

  test 'display submitter label when last comment is from submitter' do
    product = products(:product8)
    # Ensure product has comment from submitter
    Comment.create!(
      user: product.user,
      commentable: product,
      description: 'submitter comment'
    )
    product.reload

    visit_with_auth '/products/unchecked', 'komagata'
    product_item = find("a[href='/products/#{product.id}']").ancestor('.card-list-item')
    within product_item do
      assert_selector '.card-list-item-meta__item', text: '提出者'
    end
  end

  test 'display approved stamp on checked product' do
    product = products(:product3)
    assert product.checks.present?

    visit_with_auth '/products', 'komagata'
    product_item = find("a[href='/products/#{product.id}']").ancestor('.card-list-item')
    within product_item do
      assert_selector '.stamp.stamp-approve'
      assert_text '合格'
    end
  end

  test 'display elapsed days groups on unassigned page' do
    visit_with_auth '/products/unassigned', 'komagata'

    within '.page-body__column.is-main' do
      assert_selector '.card-header.a-elapsed-days'
    end

    within '.page-body__column.is-sub' do
      assert_selector '.page-nav.a-card'
      assert_selector '.elapsed-days'
    end
  end

  test 'elapsed days navigation links work on unassigned page' do
    visit_with_auth '/products/unassigned', 'komagata'

    within '.page-nav__items.elapsed-days' do
      first_link = first('.page-nav__item-link')
      href = first_link[:href]
      assert_match(/#elapsed-\d+days/, href)
    end
  end

  test 'display time until next elapsed days on unassigned page' do
    visit_with_auth '/products/unassigned', 'komagata'

    # Find a product that should show "次の経過日数まで"
    assert_selector '.a-meta', text: /次の経過日数まで/
  end

  test 'display training end date for trainee on unchecked page' do
    trainee = users(:kensyu)
    trainee.update!(training_ends_on: Date.current + 10.days)
    Product.create!(
      body: 'trainee product',
      user: trainee,
      practice: practices(:practice5),
      published_at: Time.current
    )

    visit_with_auth '/products/unchecked', 'komagata'

    assert_selector '.a-meta__label', text: '研修終了予定日'
  end

  test 'empty message shown when no products on self_assigned' do
    visit_with_auth '/products/self_assigned', 'komagata'
    assert_selector '.o-empty-message'
    assert_text '提出物はありません'
  end
end
