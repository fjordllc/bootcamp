# frozen_string_literal: true

require 'application_system_test_case'

class InquiryTest < ApplicationSystemTestCase
  test 'GET /inquiry/new' do
    visit '/inquiry/new'
    assert_equal 'お問い合わせ | FJORD BOOT CAMP（フィヨルドブートキャンプ）', title
  end
end
