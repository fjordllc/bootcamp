# frozen_string_literal: true

require 'application_system_test_case'

class User::ReportsTest < ApplicationSystemTestCase
  test 'show listing reports' do
    visit_with_auth "/users/#{users(:hatsuno).id}/reports", 'hatsuno'
    assert_equal 'hatsunoの日報 | FJORD BOOT CAMP（フィヨルドブートキャンプ）', title
  end
end
