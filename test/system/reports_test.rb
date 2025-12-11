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

  test 'report has a comment form ' do
    visit_with_auth "/reports/#{reports(:report1).id}", 'mentormentaro'
    assert_selector '.thread-comment-form'
  end

  test 'show number of comments' do
    visit_with_auth report_path(reports(:report1)), 'komagata'
    within(:css, '.is-emphasized') do
      assert_text '2'
    end
  end

  test 'hide user icon from recent reports in report show' do
    visit_with_auth report_path(reports(:report1)), 'komagata'
    assert_no_selector('.card-list-item__user')
  end

  test 'display user icon in reports' do
    visit_with_auth reports_path, 'komagata'
    assert_selector('.card-list-item__user')
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
end
