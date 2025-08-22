# frozen_string_literal: true

require 'application_system_test_case'

class Report::UnconfirmedLinksOpenTest < ApplicationSystemTestCase
  driven_by :rack_test

  setup do
    @mentor = users(:komagata)
    @student = users(:kimura)
  end

  test 'mentor sees bulk open button when unchecked reports exist' do
    visit_with_auth reports_unchecked_index_path, 'komagata'
    assert_selector 'button', text: '未チェックの日報を一括で開く'
  end

  test 'mentor does not see bulk open button when no unchecked reports exist' do
    # すべてのレポートにチェックをつけて「未チェックをゼロ」にする
    Report.unchecked.find_each do |report|
      report.checks.create!(user: @mentor)
    end

    visit_with_auth reports_unchecked_index_path, 'komagata'
    assert_no_selector 'button', text: '未チェックの日報を一括で開く'
  end

  test 'non-mentor never sees bulk open button' do
    visit_with_auth reports_unchecked_index_path, 'kimura'
    assert_no_selector 'button', text: '未チェックの日報を一括で開く'
  end
end
