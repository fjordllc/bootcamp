# frozen_string_literal: true

require 'application_system_test_case'

module Products
  class PermissionTest < ApplicationSystemTestCase
    test 'admin can delete a product' do
      product = products(:product1)
      visit_with_auth "/products/#{product.id}", 'komagata'
      accept_confirm do
        click_link '削除'
      end
      assert_text '提出物を削除しました。'
    end
  end
end
