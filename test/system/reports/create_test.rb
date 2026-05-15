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

    test 'set default learning start time from user learning time frame' do
      travel_to Time.zone.local(2025, 1, 1, 10, 0, 0) do
        visit_with_auth '/reports/new', 'kimura'

        start_hour, start_minutes = learning_start_time_select_values

        assert_equal '10', start_hour
        assert_equal '00', start_minutes

        user = users(:kimura)
        one_hour_ago = 1.hour.ago
        week_day = LearningTimeFrame::WEEK_DAY_NAMES_JA[one_hour_ago.wday]
        frame_hour = one_hour_ago.hour
        frame = LearningTimeFrame.find_by!(week_day: week_day, activity_time: frame_hour)
        LearningTimeFramesUser.create!(user: user, learning_time_frame: frame)

        visit_with_auth '/reports/new', 'kimura'

        start_hour, start_minutes = learning_start_time_select_values

        assert_equal '09', start_hour
        assert_equal '00', start_minutes
      end
    end

    test 'set current time when scheduled learning start time is in the future' do
      travel_to Time.zone.local(2025, 1, 1, 10, 0, 0) do
        user = users(:kimura)
        one_hour_since = 1.hour.since
        week_day = LearningTimeFrame::WEEK_DAY_NAMES_JA[one_hour_since.wday]
        frame_hour = one_hour_since.hour
        frame = LearningTimeFrame.find_by!(week_day: week_day, activity_time: frame_hour)
        LearningTimeFramesUser.create!(user: user, learning_time_frame: frame)

        visit_with_auth '/reports/new', 'kimura'

        start_hour, start_minutes = learning_start_time_select_values

        assert_equal '10', start_hour
        assert_equal '00', start_minutes
      end
    end

    private

    def learning_start_time_select_values
      hour_select, minutes_select = first('.learning-time').all('.learning-time__started-at select')
      [hour_select.value, minutes_select.value]
    end
  end
end
