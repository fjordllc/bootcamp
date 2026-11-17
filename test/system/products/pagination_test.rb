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
end
