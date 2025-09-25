# frozen_string_literal: true

require 'application_system_test_case'

class ReportsPracticeFilterTest < ApplicationSystemTestCase
  setup do
    @user = users(:kimura)
    @practice1 = practices(:practice1)
    @practice2 = practices(:practice2)
    @report1 = Report.create!(
      user: @user,
      title: 'レポート1',
      description: 'テスト用レポート1',
      reported_on: Time.zone.today
    )
    @report1.practices << @practice1

    @report2 = Report.create!(
      user: @user,
      title: 'レポート2',
      description: 'テスト用レポート2',
      reported_on: Time.zone.today - 1.day
    )
    @report2.practices << @practice2

    visit login_path
    fill_in 'メールアドレス', with: @user.email
    fill_in 'パスワード', with: 'testtest'
    click_button 'ログイン'
  end

  test 'GET filter by practice works' do
    visit reports_path(practice_id: @practice1.id)
    assert_text 'レポート1', wait: 5
    assert_no_text 'レポート2', wait: 5
  end

  test 'practice filter is hidden when unchecked parameter is present' do
    visit unchecked_reports_path
    assert_no_selector 'select#js-choices-single-select', wait: 5
  end
end
