# frozen_string_literal: true

require 'application_system_test_case'

module RegularEvents
  class WipTest < ApplicationSystemTestCase
    setup do
      @raise_server_errors = Capybara.raise_server_errors
      stub_request(:post, 'https://discord.com/api/webhooks/0123456789/all')
      stub_request(:post, 'https://discord.com/api/webhooks/0123456789/admin')
      stub_request(:post, 'https://discord.com/api/webhooks/0123456789/mentor')
    end

    teardown do
      Capybara.raise_server_errors = @raise_server_errors
    end

    test 'create regular event as WIP' do
      visit_with_auth new_regular_event_path, 'komagata'
      wait_for_regular_event_form
      # Wait for all form elements to be ready
      assert_selector 'form[name=regular_event]'
      assert_selector '.choices__inner'
      within 'form[name=regular_event]' do
        fill_in 'regular_event[title]', with: '質問相談タイム'
        first('.choices__inner').click
        find('#choices--js-choices-multiple-select-item-choice-1').click
        find('label', text: '主催者').click
        find('label', text: '質問').click
        # Wait for select fields to be ready
        assert_selector '.regular-event-repeat-rule .regular-event-repeat-rule__frequency select'
        assert_selector '.regular-event-repeat-rule .regular-event-repeat-rule__day-of-the-week select'
        first('.regular-event-repeat-rule').first('.regular-event-repeat-rule__frequency select').select('毎週')
        first('.regular-event-repeat-rule').first('.regular-event-repeat-rule__day-of-the-week select').select('月曜日')
        fill_in 'regular_event[start_at]', with: Time.zone.parse('16:00')
        fill_in 'regular_event[end_at]', with: Time.zone.parse('17:00')
        fill_in 'regular_event[description]', with: '質問相談タイムです'
      end
      # Click WIP button outside of within block as it may be outside the form
      original_count = RegularEvent.count
      click_button 'WIP'
      assert_text '定期イベントをWIPとして保存しました。', wait: 10
      assert_equal original_count + 1, RegularEvent.count
      assert_text '定期イベント編集'
    end

    test 'show regular event as WIP' do
      original_count = RegularEvent.count
      visit_with_auth new_regular_event_path, 'komagata'
      within 'form[name=regular_event]' do
        fill_in 'regular_event[title]', with: 'WIPの定期イベント表示確認用'
        first('.choices__inner').click
        find('#choices--js-choices-multiple-select-item-choice-1').click
        find('label', text: '主催者').click
        find('label', text: '質問').click
        fill_in 'regular_event[start_at]', with: Time.zone.parse('21:00')
        fill_in 'regular_event[end_at]', with: Time.zone.parse('22:00')
        fill_in 'regular_event[description]', with: '定期イベントがWIPのときの次回開催日時の表示確認を行うための定期イベント'
        click_button 'WIP'
      end
      assert_text '定期イベントをWIPとして保存しました。', wait: 10
      assert_equal original_count + 1, RegularEvent.count

      visit_with_auth regular_event_path(RegularEvent.last), 'komagata'
      assert_equal 'WIPの定期イベント表示確認用 | FBC', title
      assert_text '毎週日曜日21:00 〜 22:00（祝日は休み）'
      assert_text 'イベント編集中のため次回開催日は未定です'
      assert_text '定期イベントがWIPのときの次回開催日時の表示確認を行うための定期イベント'
    end
  end
end
