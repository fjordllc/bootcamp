# frozen_string_literal: true

require 'browserless_system_test_case'

module RegularEvents
  class ParticipationBrowserlessTest < BrowserlessSystemTestCase
    setup do
      stub_request(:post, 'https://discord.com/api/webhooks/0123456789/all')
      stub_request(:post, 'https://discord.com/api/webhooks/0123456789/admin')
      stub_request(:post, 'https://discord.com/api/webhooks/0123456789/mentor')
    end

    test 'upcoming events groups' do
      today_events_count = 6
      tomorrow_events_count = 2
      day_after_tomorrow_events_count = 4
      travel_to Time.zone.local(2017, 4, 3, 8, 0, 0) do
        visit_with_auth events_path, 'komagata'
        within('.upcoming_events_groups') do
          assert_text '近日開催のイベント'
          within('.card-list__items', text: '今日開催') do
            assert_selector('.card-list-item', count: today_events_count)
          end
          within('.card-list__items', text: '明日開催') do
            assert_selector('.card-list-item', count: tomorrow_events_count)
          end
          within('.card-list__items', text: '明後日開催') do
            assert_selector('.card-list-item', count: day_after_tomorrow_events_count)
          end
        end
      end
    end
  end
end
