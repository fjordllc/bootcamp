# frozen_string_literal: true

require 'application_system_test_case'

class User::ReportsTest < ApplicationSystemTestCase
  test 'show listing reports' do
    visit_with_auth "/users/#{users(:hatsuno).id}/reports", 'hatsuno'
    assert_equal 'hatsuno | FJORD BOOT CAMP（フィヨルドブートキャンプ）', title
  end

  test 'cannot access other users download reports' do
    visit_with_auth "/users/#{users(:hatsuno).id}/reports.md", 'yamada'
    assert_text '自分以外の日報はダウンロードすることができません'
  end
end
