# frozen_string_literal: true

require 'application_system_test_case'

class CurrentUser::ProductsTest < ApplicationSystemTestCase
  test 'show current_user products when current_user is student' do
    visit_with_auth '/current_user/products', 'kimura'
    assert_equal '自分の提出物 | FJORD BOOT CAMP（フィヨルドブートキャンプ）', title
  end
end
