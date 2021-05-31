# frozen_string_literal: true

require 'application_system_test_case'

class Product::ShowUserNameTest < ApplicationSystemTestCase
  test 'show user name next to user id' do
    login_user 'kimura', 'testtest'
    visit "/products/#{products(:product1).id}"
    assert_text 'yamada (Yamada Taro)'
  end
end
