# frozen_string_literal: true

require 'browserless_system_test_case'

class Events::AnnouncementBrowserlessTest < BrowserlessSystemTestCase
  test 'checkboxes for creating an announcement are display the new event page' do
    visit_with_auth new_event_path, 'komagata'
    assert_selector 'label', text: 'イベント公開のお知らせを書く'
  end
end
