# frozen_string_literal: true

require 'application_system_test_case'

class UserDashboardTest < ApplicationSystemTestCase
  test 'show welcome message' do
    visit_with_auth '/', 'hatsuno'
    assert_text 'ようこそ'
  end

  test 'not show welcome message' do
    visit_with_auth '/', 'hatsuno'
    assert_text 'ようこそ'

    visit practice_path(practices(:practice1).id)
    click_button '着手'
    assert_selector '.is-started.is-active'

    visit '/'
    assert_selector '.page-header__title', text: 'ダッシュボード'
    assert_no_text 'ようこそ'
  end

  test 'paging niconico_calendar' do
    visit_with_auth root_path, 'hatsuno'
    today = Date.current
    last_month = today.prev_month
    visit user_path(users(:hajime).id)
    assert_text "#{today.year}年#{today.month}月"
    find('.niconico-calendar-nav__previous').click
    assert_text "#{last_month.year}年#{last_month.month}月"
  end

  test 'show mark to today on niconico_calendar' do
    today = Date.current
    visit_with_auth root_path, 'hatsuno'
    visit user_path(users(:hajime).id)
    assert_selector '.niconico-calendar__day.is-today'
    target_day = find('.niconico-calendar__day.is-today').text
    assert_equal today.day.to_s, target_day
  end

  test 'not show mark to today on niconico_calendar' do
    visit_with_auth root_path, 'hatsuno'
    visit user_path(users(:hajime).id)
    find('.niconico-calendar-nav__previous').click
    assert_text 'hajime'
    assert_no_selector '.niconico-calendar__day.is-today'
  end
end
