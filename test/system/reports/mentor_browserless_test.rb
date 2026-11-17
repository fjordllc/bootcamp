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

    test 'mentor can see comment by Pjord button' do
      visit_with_auth report_path(reports(:report5)), 'mentormentaro'
      assert_button 'ピヨルドがコメントする'
    end

    test 'admin can see comment by Pjord button' do
      visit_with_auth report_path(reports(:report5)), 'adminonly'
      assert_button 'ピヨルドがコメントする'
    end

    test 'display message to admin or mentor in report of retired user' do
      report = Report.create!(
        user: users(:yameo),
        title: '退会済みユーザーの日報',
        reported_on: '2022-01-03',
        emotion: 'positive',
        no_learn: true,
        wip: false,
        description: 'お世話になりました'
      )

      visit_with_auth report_path(report), 'komagata'
      assert_selector '.a-page-notice.is-muted.is-only-mentor', text: 'このユーザーは退会しています。'
    end
  end
end
