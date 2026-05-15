# frozen_string_literal: true

require 'application_system_test_case'

class EventCommentsTest < ApplicationSystemTestCase
  test 'post new comment for event' do
    visit_with_auth "/events/#{events(:event1).id}", 'komagata'

    # Wait for form to load
    find('.thread-comment-form__form')

    within('.thread-comment-form__form') do
      fill_in('new_comment[description]', with: 'test')
    end

    # Click preview tab and verify content
    tabs = all('.a-form-tabs__tab.js-tabs__tab')
    if tabs.size > 1
      tabs[1].click
      assert_text 'test'
    end

    click_button 'コメントする'
    assert_text 'test'
    assert_text 'Watch中'
  end
end
