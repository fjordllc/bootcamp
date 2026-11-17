# frozen_string_literal: true

require 'browserless_system_test_case'

class ReportsBrowserlessTest < BrowserlessSystemTestCase
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
    assert_selector '.is-emphasized', text: '2'
  end

  test 'display user icon in reports' do
    visit_with_auth reports_path, 'komagata'
    assert_selector('.card-list-item__user')
  end
end
