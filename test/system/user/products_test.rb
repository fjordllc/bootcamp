# frozen_string_literal: true

require 'application_system_test_case'

class User::ProductsTest < ApplicationSystemTestCase
  test 'show self assigned products to mentor' do
    self_assigned_products_url = "/users/#{users(:with_hyphen).id}/products?target=self_assigned"
    visit_with_auth self_assigned_products_url, 'komagata'
    assert_no_text products(:product16).practice.title

    visit_with_auth "/products/#{products(:product16).id}", 'komagata'
    click_button '担当する'
    assert_button '担当から外れる'

    visit_with_auth self_assigned_products_url, 'komagata'
    assert_text products(:product16).practice.title
  end
end
