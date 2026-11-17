# frozen_string_literal: true

require 'browserless_system_test_case'

module Reports
  class MentorBrowserlessTest < BrowserlessSystemTestCase
    setup do
      stub_request(:post, 'https://discord.com/api/webhooks/0123456789/all')
      stub_request(:post, 'https://discord.com/api/webhooks/0123456789/introduction')
      stub_request(:post, 'https://discord.com/api/webhooks/0123456789/mentor')
      stub_request(:post, 'https://discord.com/api/webhooks/0123456789/admin')
    end

    test 'display recently reports' do
      visit_with_auth report_path(reports(:report10)), 'mentormentaro'
      assert_selector 'img[alt="positive"]'
      assert_text '今日は頑張りました'
    end
  end
end
