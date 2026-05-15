# frozen_string_literal: true

require 'application_system_test_case'

class PageCommentsTest < ApplicationSystemTestCase
  test 'post new comment for page' do
    visit_with_auth "/pages/#{pages(:page1).id}", 'komagata'
    within('.thread-comment-form__form') do
      fill_in('new_comment[description]', with: 'test')
    end
    all('.a-form-tabs__tab.js-tabs__tab')[1].click
    assert_text 'test'
    click_button 'コメントする'
    assert_text 'test'
    assert_text 'Watch中'
  end
end
