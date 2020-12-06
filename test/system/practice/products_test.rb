# frozen_string_literal: true

require 'application_system_test_case'

class Practice::ProductsTest < ApplicationSystemTestCase
  test 'show listing products' do
    login_user 'komagata', 'testtest'
    visit "/practices/#{practices(:practice1).id}/products"
    assert_equal 'OS X Mountain Lionをクリーンインストールする | FJORD BOOT CAMP（フィヨルドブートキャンプ）', title
  end
end
