# frozen_string_literal: true

require 'application_system_test_case'

class WatchesTest < ApplicationSystemTestCase
  test 'after posting a comment, clicking the Watch button removes the Watch.' do
    visit_with_auth "/announcements/#{announcements(:announcement1).id}", 'komagata'
    within('.thread-comment-form__form') do
      fill_in('new_comment[description]', with: 'test')
    end
    all('.a-form-tabs__tab.js-tabs__tab')[1].click
    click_button 'コメントする'
    assert_text 'Watch中'
    find('#watch-button').click
    assert_text 'Watch'
    visit_with_auth '/current_user/watches', 'komagata'
    assert_no_text 'お知らせ1'
  end

  test 'after posting a answer, clicking the Watch button removes the Watch.' do
    visit_with_auth "/questions/#{questions(:question2).id}", 'komagata'
    within('.thread-comment-form__form') do
      fill_in('answer[description]', with: 'test')
    end
    page.all('.a-form-tabs__tab.js-tabs__tab')[1].click
    click_button 'コメントする'
    assert_text 'Watch中'
    find('#watch-button').click
    assert_text 'Watch'
    visit_with_auth '/current_user/watches', 'komagata'
    assert_no_text 'injectとreduce'
  end
end
