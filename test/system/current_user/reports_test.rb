# frozen_string_literal: true

require 'application_system_test_case'

class CurrentUser::ReportsTest < ApplicationSystemTestCase
  test 'show current_user reports when current_user is student' do
    visit_with_auth '/current_user/reports', 'hatsuno'
    assert_equal 'hatsunoの日報 | FJORD BOOT CAMP（フィヨルドブートキャンプ）', title
  end
end
