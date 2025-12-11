# frozen_string_literal: true

require 'application_system_test_case'

module Reports
  class CreateTest < ApplicationSystemTestCase
    setup do
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
  end
end
