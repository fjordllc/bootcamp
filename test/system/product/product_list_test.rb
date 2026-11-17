# frozen_string_literal: true

require 'application_system_test_case'

class Product::ProductListTest < ApplicationSystemTestCase
  test 'display product list item with user info on products page' do
    visit_with_auth '/products', 'komagata'
    within first('.card-list-item') do
      assert_selector '.card-list-item__user-icon'
      assert_selector '.card-list-item-title__title'
      assert_selector '.a-user-name'
    end
  end

  test 'display submission and update time on product list' do
    visit_with_auth '/products/unchecked', 'komagata'
    within first('.card-list-item:not(.is-wip)') do
      assert_selector '.a-meta__label', text: '提出'
      assert_selector '.a-meta__label', text: '更新'
    end
  end

  test 'filter buttons work on unchecked page' do
    visit_with_auth '/products/unchecked', 'komagata'

    assert_selector '.pill-nav'
    within '.pill-nav' do
      assert_link '全て'
      assert_link '未返信'

      click_link '未返信'
    end
    assert_current_path(%r{/products/unchecked\?target=unchecked_no_replied})

    within '.pill-nav' do
      click_link '全て'
    end
    assert_current_path(%r{/products/unchecked\?target=unchecked_all})
  end

  test 'filter buttons work on self_assigned page' do
    checker = users(:machida)
    Product.create!(
      body: 'test',
      user: users(:kimura),
      practice: practices(:practice5),
      checker_id: checker.id
    )

    visit_with_auth '/products/self_assigned', 'machida'

    within '.pill-nav' do
      assert_link '全て'
      assert_link '未返信'

      click_link '未返信'
    end
    assert_current_path(%r{/products/self_assigned\?target=self_assigned_no_replied})

    within '.pill-nav' do
      click_link '全て'
    end
    assert_current_path(%r{/products/self_assigned\?target=self_assigned_all})
  end

  test 'assign button works on unchecked page' do
    visit_with_auth '/products/unchecked', 'komagata'

    within first('.card-list-item') do
      assert_button '担当する'
      click_button '担当する'
      assert_button '担当から外れる'
    end
  end

  test 'unassign button works after assigning' do
    visit_with_auth '/products/unchecked', 'komagata'

    within first('.card-list-item') do
      click_button '担当する'
      assert_button '担当から外れる'
      click_button '担当から外れる'
      assert_button '担当する'
    end
  end

  test 'pagination works on unchecked page' do
    visit_with_auth '/products/unchecked', 'komagata'

    if Product.unhibernated_user_products.unchecked.not_wip.count > 50
      within first('.pagination') do
        assert_link '2'
      end
    else
      assert_no_selector '.pagination'
    end
  end
end
