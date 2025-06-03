# frozen_string_literal: true

require 'application_system_test_case'

class ReportWipTest < ApplicationSystemTestCase
  setup do
    @komagata = users(:komagata)
    @kimura = users(:kimura)
  end

  test 'create report as WIP' do
    visit_with_auth '/reports/new', 'komagata'
    within('form[name=report]') do
      fill_in('report[title]', with: 'test title')
      fill_in('report[description]', with: 'test')
    end
    click_button 'WIP'
    assert_text '日報をWIPとして保存しました。'
  end

  test 'change report status to wip' do
    report = reports(:report15)
    visit_with_auth "/reports/#{report.id}", 'hajime'

    click_link '内容修正'
    assert_text 'この日報はすでに提出済みです。'
    click_button 'WIP'
    assert_no_text 'この日報はすでに提出済みです。'
  end

  test 'display report interval for mentor while undoing wip' do
    visit_with_auth report_path(reports(:report32)), 'komagata'
    assert_selector '.a-page-notice.is-only-mentor.is-danger', text: '10日ぶりの日報です。'

    visit_with_auth report_path(reports(:report33)), 'kananashi'
    click_link '内容修正'
    click_button '提出'

    visit_with_auth report_path(reports(:report32)), 'komagata'
    assert_no_selector '.a-page-notice.is-only-mentor.is-danger', text: '9日ぶりの日報です。'
  end

  test 'submit wip report with error' do
    report = reports(:report9)
    visit_with_auth "/reports/#{report.id}", 'sotugyou'

    click_link '内容修正'
    uncheck '学習時間は無し', allow_label_click: true
    click_link '学習時間追加'

    first('.learning-time').all('.learning-time__started-at select')[0].select('07')
    first('.learning-time').all('.learning-time__started-at select')[1].select('30')
    first('.learning-time').all('.learning-time__finished-at select')[0].select('07')
    first('.learning-time').all('.learning-time__finished-at select')[1].select('30')

    click_button '提出'
    assert_text '学習時間は不正な値です'
    assert_no_text 'この日報はすでに提出済みです。'
    assert_button '提出'
  end
end
