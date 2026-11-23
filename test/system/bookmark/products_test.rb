# frozen_string_literal: true

require 'application_system_test_case'

class Bookmark::ProductTest < ApplicationSystemTestCase
  setup do
    @product = products(:product1)
  end

  test 'bookmark product' do
    visit_with_auth "/products/#{@product.id}", 'komagata'
    wait_for_javascript_components
    find('#bookmark-button').click
    wait_for_javascript_components
    assert_selector '#bookmark-button.is-active'
    assert_no_selector '#bookmark-button.is-inactive'

    visit '/current_user/bookmarks'
    assert_text @product.title
  end
end
