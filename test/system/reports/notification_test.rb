# frozen_string_literal: true

require 'application_system_test_case'

module Reports
  class NotificationTest < ApplicationSystemTestCase
    setup do
      stub_request(:post, 'https://discord.com/api/webhooks/0123456789/all')
      stub_request(:post, 'https://discord.com/api/webhooks/0123456789/introduction')
      stub_request(:post, 'https://discord.com/api/webhooks/0123456789/mentor')
      stub_request(:post, 'https://discord.com/api/webhooks/0123456789/admin')
    end

    test 'create a report' do
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

      click_button '提出'

      assert_text '日報を保存しました。'
      assert_text Time.current.strftime('%Y年%m月%d日')
      assert_text 'Watch中'
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
  end
end
