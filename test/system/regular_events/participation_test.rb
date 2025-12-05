# frozen_string_literal: true

require 'application_system_test_case'

module RegularEvents
  class ParticipationTest < ApplicationSystemTestCase
    setup do
      stub_request(:post, 'https://discord.com/api/webhooks/0123456789/all')
      stub_request(:post, 'https://discord.com/api/webhooks/0123456789/admin')
      stub_request(:post, 'https://discord.com/api/webhooks/0123456789/mentor')
    end

    test 'show participation link during opening' do
      regular_event = regular_events(:regular_event1)
      visit_with_auth regular_event_path(regular_event), 'kimura'
      assert_link '参加申込'
    end

    test 'user can participate in an regular event' do
      regular_event = regular_events(:regular_event1)
      visit_with_auth regular_event_path(regular_event), 'kimura'
      assert_difference 'regular_event.participants.count', 1 do
        accept_confirm do
          click_link '参加申込'
        end
        assert_text '参加登録しました。'
      end
    end

    test 'user can cancel regular event' do
      regular_event = regular_events(:regular_event1)
      visit_with_auth regular_event_path(regular_event), 'hatsuno'
      assert_difference 'regular_event.participants.count', -1 do
        accept_confirm do
          click_link '参加を取り消す'
        end
        assert_text '参加を取り消しました。'
      end
    end

    test 'turn on the watch when attend an regular event' do
      regular_event = regular_events(:regular_event1)
      visit_with_auth regular_event_path(regular_event), 'kimura'
      accept_confirm do
        click_link '参加申込'
      end
      assert_text 'Watch中'
    end

    test 'admin can remove others from participation' do
      regular_event = regular_events(:regular_event1)
      visit_with_auth regular_event_path(regular_event), 'komagata'
      assert_difference 'regular_event.participants.count', -1 do
        accept_confirm do
          within('.a-card.participants') do
            first('a', text: '削除する').click
          end
        end
        assert_text '参加を取り消しました。'
      end
    end
  end
end
