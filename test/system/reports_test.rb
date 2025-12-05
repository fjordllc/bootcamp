# frozen_string_literal: true

require 'application_system_test_case'

class ReportsTest < ApplicationSystemTestCase
  setup do
    @komagata = users(:komagata)
    @kimura = users(:kimura)
    stub_request(:post, 'https://discord.com/api/webhooks/0123456789/all')
    stub_request(:post, 'https://discord.com/api/webhooks/0123456789/introduction')
    stub_request(:post, 'https://discord.com/api/webhooks/0123456789/mentor')
    stub_request(:post, 'https://discord.com/api/webhooks/0123456789/admin')
  end

  test 'create a report' do
    visit_with_auth '/reports/new', 'komagata'
    wait_for_report_form
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

  test 'report has a comment form ' do
    visit_with_auth "/reports/#{reports(:report1).id}", 'mentormentaro'
    assert_selector '.thread-comment-form'
  end

  test 'reports are ordered in descending of reported_on' do
    visit_with_auth reports_path, 'kimura'
    precede = reports(:report15).title
    succeed = reports(:report16).title
    assert_text '頑張りました'
    assert_text '頑張れませんでした'
    within '.card-list__items' do
      assert page.text.index(precede) < page.text.index(succeed)
    end
  end

  test 'reports are ordered in descending of created_at if reported_on is same' do
    visit_with_auth reports_path, 'kimura'
    precede = reports(:report18).title
    succeed = reports(:report17).title

    within '.card-list__items' do
      assert page.text.index(precede) < page.text.index(succeed)
    end
  end

  test 'show number of comments' do
    visit_with_auth report_path(reports(:report1)), 'komagata'
    within(:css, '.is-emphasized') do
      assert_text '2'
    end
  end

  test 'notify to chat after create a report' do
    visit_with_auth '/reports/new', 'kimura'
    wait_for_report_form
    within('form[name=report]') do
      fill_in('report[title]', with: 'test title')
      fill_in('report[description]', with: 'test')
      fill_in('report[reported_on]', with: Time.current)
    end

    first('.learning-time').all('.learning-time__started-at select')[0].select('07')
    first('.learning-time').all('.learning-time__started-at select')[1].select('30')
    first('.learning-time').all('.learning-time__finished-at select')[0].select('08')
    first('.learning-time').all('.learning-time__finished-at select')[1].select('30')

    mock_log = []
    stub_info = proc { |i| mock_log << i }

    Rails.logger.stub(:info, stub_info) do
      click_button '提出'
    end

    assert_text '日報を保存しました。'
    assert_text Time.current.strftime('%Y年%m月%d日')
    assert_text 'Watch中'
    assert_match 'Message to Discord.', mock_log.to_s
  end

  test 'celebrating one hundred reports' do
    user = users(:nippounashi)
    99.times do |i|
      Report.create!(
        user_id: user.id,
        title: "日報タイトル #{i + 1}",
        reported_on: (99 - i).days.ago,
        emotion: 'positive',
        no_learn: true,
        wip: false,
        description: "日報の内容 #{i + 1}"
      )
    end
    visit_with_auth '/reports/new', 'nippounashi'
    within('form[name=report]') do
      fill_in('report[title]', with: '100回目の日報')
      fill_in('report[description]', with: '日報の内容 100')
      fill_in('report[reported_on]', with: Time.current)

      check '学習時間は無し', allow_label_click: true
    end

    click_button '提出'
    assert_text 'おめでとう！'
    assert_text '100回目の日報を提出しました。'
  end

  test 'hide user icon from recent reports in report show' do
    visit_with_auth report_path(reports(:report1)), 'komagata'
    assert_no_selector('.card-list-item__user')
  end

  test 'display user icon in reports' do
    visit_with_auth reports_path, 'komagata'
    assert_selector('.card-list-item__user')
  end

  test 'user role class is displayed correctly in reports' do
    visit_with_auth '/reports/new', 'mentormentaro'
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

    visit_with_auth reports_path, 'kimura'
    within(first('.card-list-item__user')) do
      assert_selector('span.a-user-role.is-mentor')
    end
  end

  test 'using file uploading by file selection dialogue in textarea' do
    visit_with_auth '/reports/new', 'kensyu'
    within(:css, '.a-file-insert') do
      assert_selector 'input.file-input', visible: false
    end
    assert_equal '.file-input', find('textarea.a-text-input')['data-input']
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

  private

  def wait_for_report_form
    assert_selector 'textarea[name="report[description]"]:not([disabled])', wait: 20
  end
end
