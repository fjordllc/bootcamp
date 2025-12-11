# frozen_string_literal: true

require 'application_system_test_case'

class Products::PaginationTest < ApplicationSystemTestCase
  test 'click on the pager button' do
    login_user 'komagata', 'testtest'
    visit '/products'
    within first('.pagination') do
      find('button', text: '2').click
    end

    all('.pagination .is-active').each do |active_button|
      assert active_button.has_text? '2'
    end
    assert_current_path('/products?page=2')
  end

  test 'specify the page number in the URL' do
    login_user 'komagata', 'testtest'
    visit '/products?page=2'
    all('.pagination .is-active').each do |active_button|
      assert active_button.has_text? '2'
    end
    assert_current_path('/products?page=2')
  end

  test 'clicking the browser back button will show the previous page' do
    login_user 'komagata', 'testtest'
    visit '/products?page=2'
    within first('.pagination') do
      find('button', text: '1').click
    end
    assert_current_path('/products')
    assert_text '「プログラミング入門 - Rubyを使って」をやるの提出物'
    page.go_back
    assert_current_path('/products?page=2')
    all('.pagination .is-active').each do |active_button|
      assert active_button.has_text? '2'
    end
  end

  test 'When the number of pages is one, the pager will not be displayed' do
    count_of_delete = Product.count - Product.default_per_page
    if count_of_delete.positive?
      Product.all.each_with_index do |product, index|
        product.delete

        break if index >= count_of_delete
      end
    end

    visit_with_auth '/products', 'komagata'

    assert_not page.has_css?('.pagination')
  end
end
