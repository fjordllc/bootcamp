# frozen_string_literal: true

require 'application_system_test_case'

class EventsTest < ApplicationSystemTestCase
  setup do
    @raise_server_errors = Capybara.raise_server_errors
  end

  teardown do
    Capybara.raise_server_errors = @raise_server_errors
  end

  test 'show user name_kana next to user name' do
    event = events(:event2)
    user = event.user
    decorated_user = ActiveDecorator::Decorator.instance.decorate(user)
    visit_with_auth event_path(event), 'kimura'
    assert_text decorated_user.long_name
  end

  test 'show user full name on list page' do
    visit_with_auth '/events', 'kimura'
    assert_text 'kimura (キムラ タダシ)'
  end

  test 'show pagination' do
    visit_with_auth '/events', 'kimura'
    assert_selector 'nav.pagination', count: 2

    first('.pagination__item-link', text: '2').click
    assert_equal 2, page.all('.pagination__item-link.is-active', text: '2').count
    first('.pagination__item-link', text: '1').click
    assert_equal 2, page.all('.pagination__item-link.is-active', text: '1').count
  end

  test 'using file uploading by file selection dialogue in textarea' do
    visit_with_auth new_event_path, 'komagata'
    within(:css, '.a-file-insert') do
      assert_selector 'input.file-input', visible: false
    end
    assert_equal '.file-input', find('textarea.a-text-input')['data-input']
  end

  test 'edit only creator or mentor' do
    visit_with_auth edit_event_path(events(:event1)), 'kimura'
    assert_text '特別イベント編集'

    visit_with_auth edit_event_path(events(:event1)), 'komagata'
    assert_text '特別イベント編集'

    Capybara.raise_server_errors = false
    visit_with_auth edit_event_path(events(:event1)), 'hajime'
    assert_text 'ActiveRecord::RecordNotFound'
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
