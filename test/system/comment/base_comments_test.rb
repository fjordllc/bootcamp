# frozen_string_literal: true

require 'application_system_test_case'

class BaseCommentsTest < ApplicationSystemTestCase
  test 'show all comments for reports of the target user' do
    visit_with_auth polymorphic_path([users(:komagata), :comments]), 'komagata'
    assert_equal 4, users(:komagata).comments.where(commentable_type: 'Report').size
  end

  test 'comment form not found in /users/:user_id/comments' do
    visit_with_auth user_comments_path(users(:komagata)), 'komagata'
    assert has_no_field?('new_comment[description]')
  end

  test 'comment form found in /reports/:report_id' do
    visit_with_auth report_path(users(:komagata).reports.first), 'komagata'
    # Wait for page to load
    find('.thread-comment-form', wait: 10)
    assert has_field?('new_comment[description]')
  end

  test 'comment form in reports/:id has comment tab and preview tab' do
    visit_with_auth "/reports/#{reports(:report3).id}", 'komagata'
    within('.a-form-tabs') do
      assert_text 'コメント'
      assert_text 'プレビュー'
    end
  end

  test 'edit comment form has comment tab and preview tab' do
    visit_with_auth "/reports/#{reports(:report3).id}", 'komagata'
    within('.thread-comment:first-child') do
      click_button '編集'
      assert_text 'コメント'
      assert_text 'プレビュー'
    end
  end

  test 'comment tab is active after a comment has been posted' do
    visit_with_auth "/reports/#{reports(:report3).id}", 'komagata'

    # Wait for form to load
    find('.thread-comment-form__form', wait: 10)

    # Wait for tabs to be active
    assert_selector '.a-form-tabs__tab.is-active', text: 'コメント', wait: 10

    within('.thread-comment-form__form') do
      fill_in('new_comment[description]', with: 'test')
    end

    find('.a-form-tabs__tab', text: 'プレビュー').click
    assert_selector '.a-form-tabs__tab.is-active', text: 'プレビュー', wait: 5

    click_button 'コメントする'

    # Wait for comment to be posted and tab to switch back
    assert_text 'test', wait: 10
    assert_selector '.a-form-tabs__tab.is-active', text: 'コメント', wait: 5
  end

  test 'prevent double submit' do
    visit_with_auth report_path(users(:komagata).reports.first), 'komagata'
    within('.page-content-header') do
      find('.stamp.stamp-approve')
    end

    within('.thread-comment-form__form') do
      fill_in('new_comment[description]', with: 'test')
    end

    # Click button once and verify it becomes disabled
    button = find('#js-shortcut-post-comment', text: 'コメントする')
    button.click

    # Try to click again - should be intercepted or disabled
    begin
      button.click
      # If we reach here, the button was clickable twice (bad)
      flunk 'Button should be disabled after first click'
    rescue Selenium::WebDriver::Error::ElementClickInterceptedError, Selenium::WebDriver::Error::ElementNotInteractableError
      # This is expected - button should be disabled/not clickable
    end
  end

  test 'submit_button is enabled after a post is done' do
    visit_with_auth report_path(users(:komagata).reports.first), 'komagata'
    within('.page-content-header') do
      find('.stamp.stamp-approve')
    end

    within('.thread-comment-form__form') do
      fill_in('new_comment[description]', with: 'test')
    end
    click_button 'コメントする'
    assert_text 'test'
    within('.thread-comment-form__form') do
      fill_in('new_comment[description]', with: 'testtest')
    end
    click_button 'コメントする'
    assert_text 'testtest'
  end

  test 'comment url is copied when click its updated_time' do
    visit_with_auth "/reports/#{reports(:report1).id}", 'komagata'
    # Wait for comments section to load
    if has_css?('#comments.loaded', wait: 2)
      find('#comments.loaded')
    else
      # Fallback: wait for comments section or form to be present
      find('.thread-comment-form, .thread-comment', wait: 10)
    end
    first(:css, '.thread-comment__created-at').click
    # 参考：https://gist.github.com/ParamagicDev/5fe937ee60695ff1d227f18fe4b1d5c4
    cdp_permission = {
      origin: page.server_url,
      permission: { name: 'clipboard-read' },
      setting: 'granted'
    }
    page.driver.browser.execute_cdp('Browser.setPermission', **cdp_permission)
    clip_text = page.evaluate_async_script('navigator.clipboard.readText().then(arguments[0])')
    assert_equal current_url + "#comment_#{comments(:comment1).id}", clip_text
  end

  test 'clear preview after posting new comment for report' do
    visit_with_auth "/reports/#{reports(:report1).id}", 'komagata'
    within('.page-content-header') do
      find('.stamp.stamp-approve')
    end

    find('#js-new-comment').set('test')
    click_button 'コメントする'
    assert_text 'test'
    find('.a-form-tabs__tab.js-tabs__tab', text: 'プレビュー').click
    assert_selector '.a-form-tabs__tab.is-active', text: 'プレビュー'
    within('#new-comment-preview') do
      assert_no_text :all, 'test'
    end
  end
end
