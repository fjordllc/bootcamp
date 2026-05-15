# frozen_string_literal: true

require 'application_system_test_case'

class Practice::ProductsTest < ApplicationSystemTestCase
  test 'show listing products' do
    visit_with_auth "/practices/#{practices(:practice1).id}/products", 'komagata'
    assert_equal 'OS X Mountain Lionをクリーンインストールするの提出物 | FBC', title
  end
end
