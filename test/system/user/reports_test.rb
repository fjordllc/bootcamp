# frozen_string_literal: true

require 'application_system_test_case'

class User::ReportsTest < ApplicationSystemTestCase
  test 'show listing reports' do
    visit_with_auth "/users/#{users(:hatsuno).id}/reports", 'hatsuno'
    assert_equal 'hatsuno 日報 | FBC', title
  end

  test 'show listing reports when there is no report' do
    visit_with_auth "/users/#{users(:nippounashi).id}/reports", 'hatsuno'
    assert_text '日報はまだありません。'
  end

  test 'cannot access other users download reports' do
    visit_with_auth "/users/#{users(:hatsuno).id}/reports.md", 'kimura'
    assert_text '自分以外の日報はダウンロードすることができません'
  end
end
