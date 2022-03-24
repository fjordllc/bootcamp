# frozen_string_literal: true

require 'application_system_test_case'

class User::QuestionsTest < ApplicationSystemTestCase
  test 'show listing questions' do
    visit_with_auth "/users/#{users(:hatsuno).id}/questions", 'hatsuno'
    assert_equal 'hatsuno | FJORD BOOT CAMP（フィヨルドブートキャンプ）', title
  end

  test 'show solved and unsolved questions' do
    visit_with_auth "/users/#{users(:hajime).id}/questions", 'hajime'
    assert_text '解決済みの質問'
    assert_text '検索ワードが太字で表示されるかのテスト用の質問'
    assert_no_text '質問はありません'
  end
end
