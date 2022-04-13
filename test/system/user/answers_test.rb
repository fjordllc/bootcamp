# frozen_string_literal: true

require 'application_system_test_case'

class User::AnswersTest < ApplicationSystemTestCase
  test 'show listing answers' do
    visit_with_auth "/users/#{users(:komagata).id}/answers", 'komagata'
    assert_equal 'komagataのコメント一覧 | FJORD BOOT CAMP（フィヨルドブートキャンプ）', title
  end

  test "visit user profile page when clicked on user's name on answer" do
    visit_with_auth "/users/#{users(:komagata).id}/answers", 'komagata'
    assert_text 'どのエディターを使うのが良いでしょうか'
    click_link 'machida (Machida Teppei)', match: :first
    assert_text 'プロフィール'
    assert_text 'Machida Teppei（マチダ テッペイ）'
  end
end
