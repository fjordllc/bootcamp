# frozen_string_literal: true

require 'application_system_test_case'

class Home::NicoNicoCalendarTest < ApplicationSystemTestCase
  test 'show the Nico Nico calendar for students' do
    visit_with_auth '/', 'hajime'
    assert_text 'ニコニコカレンダー'
  end

  test 'show the Nico Nico calendar for graduates' do
    visit_with_auth '/', 'sotugyou'
    assert_text 'ニコニコカレンダー'
  end

  test 'not show the Nico Nico calendar for administrators' do
    visit_with_auth '/', 'komagata'
    assert_no_text 'ニコニコカレンダー'
  end

  test 'show the Nico Nico calendar for trainees' do
    visit_with_auth '/', 'kensyu'
    assert_text 'ニコニコカレンダー'
  end

  test 'show Nico Nico calendar page that matches URL params' do
    visit_with_auth '/?niconico_calendar=2020-01', 'hajime'
    find('.niconico-calendar-nav').assert_text '2020年1月'
  end

  test "show current month's page of Nico Nico calendar when future date is specified in URL params" do
    visit_with_auth "/?niconico_calendar=#{Time.current.next_month.strftime('%Y-%m')}", 'hajime'
    find('.niconico-calendar-nav').assert_text Time.current.strftime('%Y年%-m月')
  end

  test 'keep Nico Nico calendar page even when leave dashboard' do
    visit_with_auth '/', 'hajime'
    find('.niconico-calendar-nav__previous').click
    find('.niconico-calendar-nav').assert_text 1.month.ago.strftime('%Y年%-m月')
    find('.niconico-calendar').click_link href: /reports/, match: :first
    go_back
    find('.niconico-calendar-nav').assert_text 1.month.ago.strftime('%Y年%-m月')
    assert_current_path(/niconico_calendar=#{1.month.ago.strftime('%Y-%m')}/)
  end

  test 'set a link to the new report form at today on Nico Nico calendar' do
    visit_with_auth "/?niconico_calendar=#{Time.current.strftime('%Y-%m')}", 'hajime'
    find('.niconico-calendar').click_on Time.current.day.to_s
    assert_current_path("/reports/new?reported_on=#{Time.current.strftime('%Y-%m-%d')}")
  end

  test 'set a link to the new report form at past date on Nico Nico calendar' do
    visit_with_auth '/?niconico_calendar=2022-03', 'hajime'
    find('.niconico-calendar').click_on '1'
    assert_current_path('/reports/new?reported_on=2022-03-01')
  end

  test 'no link to the new report on future dates in the Nico Nico calendar' do
    visit_with_auth "/?niconico_calendar=#{Time.current.next_month.strftime('%Y-%m')}", 'hajime'
    assert_no_link(href: "/reports/new?reported_on=#{Time.current.next_month.strftime('%Y-%-m-%-d')}")
  end

  test 'show grass hide button for graduates' do
    visit_with_auth '/', 'kimura'
    assert_not has_button? '非表示'

    visit_with_auth '/', 'sotugyou'
    assert_selector 'h2.card-header__title', text: '学習時間'
    click_button '非表示'
    assert_no_selector 'h2.card-header__title', text: '学習時間'
  end
end
