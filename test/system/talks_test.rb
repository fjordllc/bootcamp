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

  test 'cannot access other users talk page' do
    visited_user = users(:hatsuno)
    visit_user = users(:yamada)
    visit_with_auth talk_path(visited_user.talk), 'yamada'
    assert_no_text "#{visited_user.name}さんの相談部屋"
    assert_text "#{visit_user.name}さんの相談部屋"
  end

  test 'admin can access users talk page' do
    visited_user = users(:hatsuno)
    visit_with_auth talk_path(visited_user.talk), 'komagata'
    assert_text "#{visited_user.name}さんの相談部屋"
  end
end
