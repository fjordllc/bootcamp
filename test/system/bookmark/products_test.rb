# frozen_string_literal: true

require 'application_system_test_case'

class Bookmark::ProductTest < ApplicationSystemTestCase
  setup do
    @product = products(:product1)
  end

  test 'show product bookmark on lists' do
    visit_with_auth '/current_user/bookmarks', 'kimura'
    assert_text @product.title
  end

  test 'show active button when bookmarked product' do
    visit_with_auth "/products/#{@product.id}", 'kimura'
    wait_for_vuejs
    assert_selector '#bookmark-button.is-active'
    assert_no_selector '#bookmark-button.is-inactive'
  end

  test 'show inactive button when not bookmarked product' do
    visit_with_auth "/products/#{@product.id}", 'komagata'
    wait_for_vuejs
    assert_selector '#bookmark-button.is-inactive'
    assert_no_selector '#bookmark-button.is-active'
  end

  test 'bookmark product' do
    visit_with_auth "/products/#{@product.id}", 'komagata'
    find('#bookmark-button').click
    wait_for_vuejs
    assert_selector '#bookmark-button.is-active'
    assert_no_selector '#bookmark-button.is-inactive'

    visit '/current_user/bookmarks'
    assert_text @product.title
  end

  test 'unbookmark product' do
    visit_with_auth "/products/#{@product.id}", 'kimura'
    assert_selector '#bookmark-button.is-active'
    find('#bookmark-button').click
    wait_for_vuejs
    assert_selector '#bookmark-button.is-inactive'
    assert_no_selector '#bookmark-button.is-active'

    visit '/current_user/bookmarks'
    assert_no_text @product.title
  end
end
