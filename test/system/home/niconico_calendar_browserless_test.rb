# frozen_string_literal: true

require 'browserless_system_test_case'

module Home
  class NiconicoCalendarBrowserlessTest < BrowserlessSystemTestCase
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
      assert_selector '.niconico-calendar-nav', text: '2020年1月'
    end

    test "show current month's page of Nico Nico calendar when future date is specified in URL params" do
      visit_with_auth "/?niconico_calendar=#{Time.current.next_month.strftime('%Y-%m')}", 'hajime'
      within '.niconico-calendar-nav' do
        assert_text Time.current.strftime('%Y年%-m月')
      end
    end
  end
end
