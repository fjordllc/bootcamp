# frozen_string_literal: true

require 'application_system_test_case'

class Home::EventsTest < ApplicationSystemTestCase
  test 'show job hunting events on dashboard for all user' do
    travel_to Time.zone.local(2017, 4, 2, 10, 0, 0) do
      visit_with_auth '/', 'jobseeker'
      assert_text '直近イベントの表示テスト用(当日)'
      assert_text '直近イベントの表示テスト用(翌日)'
      assert_text '就職関係かつ直近イベントの表示テスト用'
      logout

      visit_with_auth '/', 'komagata'
      assert_text '直近イベントの表示テスト用(当日)'
      assert_text '直近イベントの表示テスト用(翌日)'
      assert_text '就職関係かつ直近イベントの表示テスト用'
    end
  end

  test 'show all regular events and special events on dashbord' do
    travel_to Time.zone.local(2017, 4, 3, 8, 0, 0) do
      visit_with_auth '/', 'kimura'
      today_event_label = find('.card-list__label', text: '今日開催')
      tomorrow_event_label = find('.card-list__label', text: '明日開催')
      day_after_tomorrow_event_label = find('.card-list__label', text: '明後日開催')

      today_events_texts = [
        { category: '特別', title: '直近イベントの表示テスト用(当日)', start_at: '2017年04月03日(月) 09:00' },
        { category: '特別', title: 'kimura専用イベント', start_at: '2017年04月03日(月) 09:00' },
        { category: '輪読会', title: '月曜日開催で10:00に終了する定期イベント', start_at: '2017年04月03日(月) 09:00' },
        { category: '質問', title: '質問・雑談タイム', start_at: '2017年04月03日(月) 16:00' },
        { category: '輪読会', title: 'ダッシュボード表示確認用テスト定期イベント', start_at: '2017年04月03日(月) 21:00' },
        { category: '輪読会', title: 'ダッシュボード表示確認用テスト定期イベント', start_at: '2017年04月03日(月) 21:00' }
      ]
      tomorrow_events_texts = [
        { category: '輪読会', title: '定期イベントの検索結果テスト用', start_at: '2017年04月04日(火) 21:00' },
        { category: '特別', title: '直近イベントの表示テスト用(翌日)', start_at: '2017年04月04日(火) 22:00' }
      ]
      day_after_tomorrow_events_texts = [
        { category: '輪読会', title: 'Discord通知確認用イベント(土曜日午前8時から開催)', start_at: '2017年04月05日(水) 08:00' },
        { category: '特別', title: '直近イベントの表示テスト用(明後日)', start_at: '2017年04月05日(水) 09:00' },
        { category: '輪読会', title: '独習Git輪読会', start_at: '2017年04月05日(水) 21:00' },
        { category: '輪読会', title: '参加反映テスト用定期イベント(祝日非開催)', start_at: '2017年04月05日(水) 21:00' }
      ]

      assert_event_card(today_event_label, today_events_texts)
      assert_event_card(tomorrow_event_label, tomorrow_events_texts)
      assert_event_card(day_after_tomorrow_event_label, day_after_tomorrow_events_texts)
    end
  end

  test 'show registered to participate only participating events' do
    Event.where.not(title: ['kimura専用イベント', '直近イベントの表示テスト用(当日)']).destroy_all
    RegularEvent.where.not(title: ['ダッシュボード表示確認用テスト定期イベント', '質問・雑談タイム']).destroy_all

    travel_to Time.zone.local(2017, 4, 3, 10, 0, 0) do
      visit_with_auth '/', 'kimura'
      within all('.card-list-item')[0] do
        assert_text '直近イベントの表示テスト用(当日)'
        assert_no_text '参加'
      end
      within all('.card-list-item')[1] do
        assert_text 'kimura専用イベント'
        assert_text '参加'
      end
      within all('.card-list-item')[2] do
        assert_text '質問・雑談タイム'
        assert_no_text '参加'
      end
      within all('.card-list-item')[3] do
        assert_text 'ダッシュボード表示確認用テスト定期イベント'
        assert_text '参加'
      end
    end
  end

  test 'shows event status even if it is not held on holidays' do
    Event.destroy_all
    RegularEvent.where.not(title: 'ダッシュボード表示確認用テスト定期イベント(祝日非開催)').destroy_all

    travel_to Time.zone.parse('2023-09-18') do
      visit_with_auth '/', 'hatsuno'
      today_event_label = find('.card-list__label', text: '今日開催')
      today_events_texts = [
        {
          category: '休み',
          title: 'ダッシュボード表示確認用テスト定期イベント(祝日非開催)',
          start_at: '09月18日はお休みです。'
        }
      ]
      assert_event_card(today_event_label, today_events_texts)
    end
  end

  test 'shows event status when it is held on weekdays' do
    Event.destroy_all
    RegularEvent.where.not(title: 'ダッシュボード表示確認用テスト定期イベント(祝日非開催)').destroy_all

    travel_to Time.zone.parse('2023-09-25') do
      visit_with_auth '/', 'hatsuno'
      today_event_label = find('.card-list__label', text: '今日開催')
      today_events_texts = [
        {
          category: '輪読会',
          title: 'ダッシュボード表示確認用テスト定期イベント(祝日非開催)',
          start_at: '2023年09月25日(月) 21:00'
        }
      ]
      assert_event_card(today_event_label, today_events_texts)
    end
  end

  test 'show job hunting on job hunting related events' do
    Event.where.not(title: ['就職関係かつ直近イベントの表示テスト用']).destroy_all
    RegularEvent.destroy_all

    travel_to Time.zone.local(2017, 4, 2, 10, 0, 0) do
      visit_with_auth '/', 'kimura'
      within all('.card-list-item')[0] do
        assert_text '就職関係かつ直近イベントの表示テスト用'
        assert_text '就活関連イベント'
      end
    end
  end

  test "show my wip's event on dashboard" do
    visit_with_auth '/', 'kimura'
    click_link 'イベント'
    click_link '特別イベント作成'
    fill_in 'event[title]', with: 'WIPのイベント'
    fill_in 'event[location]', with: 'オンライン'
    fill_in 'event[capacity]', with: 100
    fill_in 'event[start_at]', with: Time.current.next_month
    fill_in 'event[end_at]', with:  Time.current.next_month + 1.hour
    fill_in 'event[open_start_at]', with: Time.current
    fill_in 'event[open_end_at]', with: Time.current + 20.days
    fill_in 'event[description]', with: 'WIPイベント本文'
    click_button 'WIP'

    visit '/'
    assert_text 'WIPで保存中'
    within '.card-list-item.is-event' do
      assert_text 'イベント'
      find_link 'WIPのイベント'
      event = Event.find_by(title: 'WIPのイベント')
      assert_text I18n.l event.updated_at
    end
  end

  private

  def event_xpath(event_label, idx)
    "#{event_label.path}/following-sibling::*[#{idx + 1}][contains(@class, 'card-list-item')]"
  end

  def assert_event_card(event_label, events_texts)
    return assert_not has_selector?(:xpath, event_xpath.call(0)) if events_texts.empty?

    events_texts.each_with_index do |event_texts, idx|
      card_list_element = find(:xpath, event_xpath(event_label, idx))
      card_list_element.assert_text(event_texts[:category])
      card_list_element.assert_text(event_texts[:title])
      card_list_element.assert_text(event_texts[:start_at])
    end
    assert_events_count(event_label, events_texts.size)
  end

  def assert_events_count(event_label, count)
    assert_no_selector(:xpath, event_xpath(event_label, count))
  end
end
