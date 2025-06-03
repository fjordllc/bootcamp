# frozen_string_literal: true

require 'application_system_test_case'

class ReportCrudTest < ApplicationSystemTestCase
  setup do
    @komagata = users(:komagata)
    @kimura = users(:kimura)
  end

  test 'create a report' do
    visit_with_auth '/reports/new', 'komagata'
    within('form[name=report]') do
      fill_in('report[title]', with: 'test title')
      fill_in('report[description]', with: 'test')
      fill_in('report[reported_on]', with: Time.current)
    end

    first('.learning-time').all('.learning-time__started-at select')[0].select('07')
    first('.learning-time').all('.learning-time__started-at select')[1].select('30')
    first('.learning-time').all('.learning-time__finished-at select')[0].select('08')
    first('.learning-time').all('.learning-time__finished-at select')[1].select('30')

    click_button '提出'
    assert_text '日報を保存しました。'
    assert_text Time.current.strftime('%Y年%m月%d日')
    assert_text 'Watch中'
  end

  test 'create a report without learning time' do
    visit_with_auth '/reports/new', 'komagata'
    within('form[name=report]') do
      fill_in('report[title]', with: 'test title')
      fill_in('report[description]', with: 'test')
      fill_in('report[reported_on]', with: Time.current)

      first('.learning-time').all('.learning-time__started-at select')[0].select('07')
      first('.learning-time').all('.learning-time__started-at select')[1].select('30')
      first('.learning-time').all('.learning-time__finished-at select')[0].select('08')
      first('.learning-time').all('.learning-time__finished-at select')[1].select('30')

      check '学習時間は無し', allow_label_click: true
    end

    click_button '提出'
    assert_text '日報を保存しました。'
    assert_text '学習時間無し'
  end

  test 'practices are displayed when updating with selecting a practice' do
    report = reports(:report10)
    visit_with_auth "/reports/#{report.id}", 'hajime'
    click_link '内容修正'

    click_button '内容変更'
    assert_text 'Terminalの基礎を覚える'
    assert_text '日報を保存しました。'
  end

  test 'practices are not displayed when updating without selecting a practice' do
    report = reports(:report10)
    visit_with_auth "/reports/#{report.id}", 'hajime'
    click_link '内容修正'
    first('.choices__button').click

    click_button '内容変更'
    assert_no_text 'Terminalの基礎を覚える'
    assert_text '日報を保存しました。'
  end

  test 'reports can be copied' do
    visit_with_auth report_path(users(:komagata).reports.first), 'komagata'
    travel 5.days do
      find('#copy').click
      assert_equal find('#report_reported_on').value, Date.current.strftime('%Y-%m-%d')
    end
  end

  test 'report has a comment form ' do
    visit_with_auth "/reports/#{reports(:report1).id}", 'mentormentaro'
    assert_selector '.thread-comment-form'
  end

  test 'reports can be checked as plain markdown' do
    visit_with_auth '/reports/new', 'kimura'
    within('form[name=report]') do
      fill_in('report[title]', with: 'check plain markdown')
      fill_in('report[description]', with: '## this is heading2')
      fill_in('report[reported_on]', with: Time.current)
    end

    all('.learning-time')[0].all('.learning-time__started-at select')[0].select('07')
    all('.learning-time')[0].all('.learning-time__started-at select')[1].select('30')
    all('.learning-time')[0].all('.learning-time__finished-at select')[0].select('08')
    all('.learning-time')[0].all('.learning-time__finished-at select')[1].select('30')

    click_button '提出'
    click_link 'Raw'
    switch_to_window windows.last
    assert_text '## this is heading2', exact: true
  end

  test 'update report without learning time' do
    visit_with_auth edit_report_path(reports(:report1)), 'komagata'
    check '学習時間は無し', allow_label_click: true
    click_button '内容変更'
    assert_text '学習時間無し'
  end

  test 'show number of comments' do
    visit_with_auth report_path(reports(:report1)), 'komagata'
    within(:css, '.is-emphasized') do
      assert_text '2'
    end
  end

  test 'open new report with a past date' do
    visit_with_auth '/reports/new?reported_on=2022-1-1', 'komagata'
    assert_equal '2022-01-01', find('#report_reported_on').value
  end

  test 'hide user icon from recent reports in report show' do
    visit_with_auth report_path(reports(:report1)), 'komagata'
    assert_no_selector('.card-list-item__user')
  end

  test 'display user icon in reports' do
    visit_with_auth reports_path, 'komagata'
    assert_selector('.card-list-item__user')
  end

  test 'URL copy button copies the current URL to the clipboard' do
    report = reports(:report10)
    visit_with_auth "/reports/#{report.id}", 'hajime'
    cdp_permission_write = {
      origin: page.server_url,
      permission: { name: 'clipboard-write' },
      setting: 'granted'
    }
    page.driver.browser.execute_cdp('Browser.setPermission', **cdp_permission_write)
    cdp_permission_read = {
      origin: page.server_url,
      permission: { name: 'clipboard-read' },
      setting: 'granted'
    }
    page.driver.browser.execute_cdp('Browser.setPermission', **cdp_permission_read)
    click_button 'URLコピー'
    clip_text = page.evaluate_async_script('navigator.clipboard.readText().then(arguments[0])')
    assert_equal current_url, clip_text
  end
end
