# frozen_string_literal: true

require 'application_system_test_case'

class User::ReportsTest < ApplicationSystemTestCase
  test 'show listing reports' do
    visit_with_auth "/users/#{users(:hatsuno).id}/reports", 'hatsuno'
    assert_equal 'hatsuno 日報 | FBC', title
  end

  test 'can use select box to filter user reports by practice' do
    visit_with_auth "/users/#{users(:hajime).id}/reports", 'kimura'

    expected_reports = users(:hajime).reports
    displayed_reports_count = all('.card-list-item-title__link').count
    assert_equal expected_reports.count, displayed_reports_count

    find('.choices__inner').click
    find('#choices--js-choices-single-select-item-choice-3', text: 'Terminalの基礎を覚える').click
    assert_text 'Terminalの基礎を覚える'

    expected_reports = Practice.find_by(title: 'Terminalの基礎を覚える').reports.where(user: users(:hajime))
    displayed_reports_count = all('.card-list-item-title__link').count
    assert_equal expected_reports.count, displayed_reports_count

    assert_text expected_reports.first.title
  end

  test 'cannot access other users download reports' do
    visit_with_auth "/users/#{users(:hatsuno).id}/reports.md", 'kimura'
    assert_text '自分以外の日報はダウンロードすることができません'
  end
end
