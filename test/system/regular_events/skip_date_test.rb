# frozen_string_literal: true

require 'application_system_test_case'

module RegularEvents
  class SkipDateTest < ApplicationSystemTestCase
    setup do
      stub_request(:post, 'https://discord.com/api/webhooks/0123456789/all')
      stub_request(:post, 'https://discord.com/api/webhooks/0123456789/admin')
      stub_request(:post, 'https://discord.com/api/webhooks/0123456789/mentor')
    end

    test 'create and show skip dates' do
      travel_to Time.zone.local(2026, 4, 1, 6, 0, 0) do
        # kimuraでログイン
        visit_with_auth new_regular_event_path, 'kimura'
        wait_for_regular_event_form
        # 作成
        within 'form[name=regular_event]' do
          fill_in 'regular_event[title]', with: 'チェリー本輪読会'
          first('.choices__inner').click
          find('#choices--js-choices-multiple-select-item-choice-1').click
          first('.regular-event-repeat-rule').first('.regular-event-repeat-rule__frequency select').select('毎週')
          first('.regular-event-repeat-rule').first('.regular-event-repeat-rule__day-of-the-week select').select('月曜日')
          fill_in 'regular_event[start_at]', with: Time.zone.parse('19:00')
          fill_in 'regular_event[end_at]', with: Time.zone.parse('20:00')
          fill_in 'regular_event[description]', with: 'テスト'
          click_on 'スキップする日を追加'
          fill_in 'スキップする日', with: Time.zone.local(2026, 4, 6).to_date
          fill_in '理由', with: '主催者の急用のため'
        end

        assert_difference 'RegularEvent.count', 1 do
          click_button '作成'
        end

        within('.event-meta__item', text: '開催日時') do
          assert_text '毎週月曜日19:00 〜 20:00（祝日は休み）'
        end

        within('.event-meta__item', text: '次回開催日') do
          assert_text '2026年04月13日'
        end

        within('.a-card', text: '今後のイベント休み予定') do
          assert_text '2026年04月06日'
          assert_text '2026年05月04日'
          assert_text '2026年07月20日'
          assert_text '2026年09月21日'
          assert_text '2026年10月12日'
        end
      end
    end

    test 'create out-of-rule skip dates and show only to organizers and mentors' do
      travel_to Time.zone.local(2026, 4, 1, 6, 0, 0) do
        # kimuraでログイン
        visit_with_auth new_regular_event_path, 'kimura'
        wait_for_regular_event_form
        # 作成
        within 'form[name=regular_event]' do
          fill_in 'regular_event[title]', with: 'チェリー本輪読会'
          first('.choices__inner').click
          find('#choices--js-choices-multiple-select-item-choice-1').click
          first('.regular-event-repeat-rule').first('.regular-event-repeat-rule__frequency select').select('毎週')
          first('.regular-event-repeat-rule').first('.regular-event-repeat-rule__day-of-the-week select').select('月曜日')
          fill_in 'regular_event[start_at]', with: Time.zone.parse('19:00')
          fill_in 'regular_event[end_at]', with: Time.zone.parse('20:00')
          fill_in 'regular_event[description]', with: 'テスト'
          click_on 'スキップする日を追加'
          fill_in 'スキップする日', with: Time.zone.local(2026, 4, 7).to_date
          fill_in '理由', with: 'この日は絶対休みたいため'
        end

        regular_event = nil

        assert_difference 'RegularEvent.count', 1 do
          click_button '作成'
          regular_event = RegularEvent.last
        end

        within('.a-card.is-out-of-rule-skip-dates') do
          assert_text '開催曜日と一致しない日がスキップ日として登録されています'
          assert_text '2026年04月07日(火)'
        end

        visit_with_auth regular_event_path(regular_event), 'komagata'

        within('.a-card.is-out-of-rule-skip-dates') do
          assert_text '開催曜日と一致しない日がスキップ日として登録されています'
          assert_text '2026年04月07日(火)'
        end

        visit_with_auth regular_event_path(regular_event), 'hajime'

        assert_no_selector('.a-card.is-out-of-rule-skip-dates')
      end
    end
  end
end
