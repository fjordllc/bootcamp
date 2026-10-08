# frozen_string_literal: true

require 'application_system_test_case'

class Products::PaginationTest < ApplicationSystemTestCase
  test 'click on the pager link' do
    login_user 'komagata', 'testtest'
    visit '/products'
    within first('.pagination') do
      click_link '2'
    end

    all('.pagination__item.is-active').each do |active_link|
      assert active_link.has_text? '2'
    end
    assert_current_path('/products?page=2')
  end

  test 'specify the page number in the URL' do
    login_user 'komagata', 'testtest'
    visit '/products?page=2'
    all('.pagination__item.is-active').each do |active_link|
      assert active_link.has_text? '2'
    end
    assert_current_path('/products?page=2')
  end

  test 'clicking the browser back button will show the previous page' do
    login_user 'komagata', 'testtest'
    visit '/products?page=2'
    within first('.pagination') do
      click_link '1'
    end
    # Kaminari may redirect to either /products or /products?page=1 for page 1
    assert_match(%r{/products(\?page=1)?$}, current_path)
    assert_text '「プログラミング入門 - Rubyを使って」をやるの提出物'
    page.go_back
    assert_current_path('/products?page=2')
    all('.pagination__item.is-active').each do |active_link|
      assert active_link.has_text? '2'
    end
  end

  test 'When the number of pages is one, the pager will not be displayed' do
    count_of_delete = Product.count - Product.default_per_page
    Product.where.missing(:product_ai_review).limit(count_of_delete + 1).each(&:delete) if count_of_delete.positive?

    visit_with_auth '/products', 'komagata'

    assert_not page.has_css?('.pagination')
  end
end
