# frozen_string_literal: true

require 'browserless_system_test_case'

module Users
  class NiconicoCalendarBrowserlessTest < BrowserlessSystemTestCase
    test 'show mark to today on niconico_calendar' do
      today = Date.current
      visit_with_auth root_path, 'hatsuno'
      visit user_path(users(:hajime).id)
      assert_selector '.niconico-calendar__day.is-today'
      target_day = find('.niconico-calendar__day.is-today').text
      assert_equal today.day.to_s, target_day
    end
  end
end
