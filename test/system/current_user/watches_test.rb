# frozen_string_literal: true

require 'application_system_test_case'

class CurrentUser::WatchesTest < ApplicationSystemTestCase
  test 'show current_user watches when current_user is student' do
    visit_with_auth '/current_user/watches', 'kimura'
    assert_equal '自分のWatch中 | FJORD BOOT CAMP（フィヨルドブートキャンプ）', title
  end
end
