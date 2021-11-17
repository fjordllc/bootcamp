# frozen_string_literal: true

require 'application_system_test_case'

class PagesTest < ApplicationSystemTestCase
  test 'admin can access talks page' do
    visit_with_auth '/talks', 'komagata'
    assert_equal '相談部屋 | FJORD BOOT CAMP（フィヨルドブートキャンプ）', title
  end

  test 'non-admin user cannot access talks page' do
    visit_with_auth '/talks', 'kimura'
    assert_text '管理者としてログインしてください'
  end
end
