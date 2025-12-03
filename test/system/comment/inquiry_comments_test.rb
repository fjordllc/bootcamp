# frozen_string_literal: true

require 'application_system_test_case'

class InquiryCommentsTest < ApplicationSystemTestCase
  test 'post new comment for inquiry' do
    visit_with_auth "/admin/inquiries/#{inquiries(:inquiry1).id}", 'komagata'
    within('.thread-comment-form__form') do
      fill_in('new_comment[description]', with: 'test')
    end
    all('.a-form-tabs__tab.js-tabs__tab')[1].click
    assert_text 'test'
    click_button 'コメントする'
    assert_text 'test'
  end

  test 'comment form found in /admin/inquiries/:inquiry_id' do
    visit_with_auth "/admin/inquiries/#{inquiries(:inquiry1).id}", 'komagata'
    assert has_field?('new_comment[description]')
  end

  test 'comment form in inquiry/:id has comment tab and preview tab' do
    visit_with_auth "/admin/inquiries/#{inquiries(:inquiry1).id}", 'komagata'
    within('.a-form-tabs') do
      assert_text 'コメント'
      assert_text 'プレビュー'
    end
  end

  test 'edit comment form has comment tab and preview tab at inquiry' do
    visit_with_auth "/admin/inquiries/#{inquiries(:inquiry1).id}", 'komagata'
    within('.thread-comment:first-child') do
      click_button '編集'
      assert_text 'コメント'
      assert_text 'プレビュー'
    end
  end

  test 'post new comment with emoji for inquiry' do
    visit_with_auth "/admin/inquiries/#{inquiries(:inquiry1).id}", 'komagata'
    # Wait for comments section to load
    if has_css?('#comments.loaded')
      find('#comments.loaded')
    else
      # Fallback: wait for comments section or form to be present
      find('.thread-comment-form, .thread-comment')
    end

    max_attempts = 10
    max_attempts.times do |attempt|
      find('#js-new-comment').set('')
      find('#js-new-comment').set("絵文字の補完テスト: :cat\n")
      break if find('#js-new-comment').value == '絵文字の補完テスト: 😺 '

      sleep 0.5 if attempt < max_attempts - 1
    end

    click_button 'コメントする'
    assert_text '絵文字の補完テスト: 😺'
  end

  test 'post new comment with image for inquiry' do
    visit_with_auth "/admin/inquiries/#{inquiries(:inquiry1).id}", 'komagata'
    # Wait for comments section to load
    if has_css?('#comments.loaded')
      find('#comments.loaded')
    else
      # Fallback: wait for comments section or form to be present
      find('.thread-comment-form, .thread-comment')
    end
    find('#js-new-comment').set('画像付きで説明します。 ![Image](https://example.com/test.png)')
    click_button 'コメントする'
    assert_text '画像付きで説明します。'
    assert_match '<a href="https://example.com/test.png" target="_blank" rel="noopener noreferrer"><img src="https://example.com/test.png" alt="Image"></a>',
                 page.body
  end

  test 'post new comment with linked image for inquiry' do
    visit_with_auth "/admin/inquiries/#{inquiries(:inquiry1).id}", 'komagata'
    # Wait for comments section to load
    if has_css?('#comments.loaded')
      find('#comments.loaded')
    else
      # Fallback: wait for comments section or form to be present
      find('.thread-comment-form, .thread-comment')
    end
    find('#js-new-comment').set('[![Image](https://example.com/test.png)](https://example.com)')
    click_button 'コメントする'
    assert_text 'コメントを投稿しました！'
    assert_match '<a href="https://example.com" target="_blank" rel="noopener"><img src="https://example.com/test.png" alt="Image"></a>', page.body
  end

  test 'edit the comment for inquiry' do
    visit_with_auth "/admin/inquiries/#{inquiries(:inquiry1).id}", 'komagata'
    within('.thread-comment:first-child') do
      click_button '編集'
      within(:css, '.thread-comment-form__form') do
        fill_in('comment[description]', with: 'edit test')
      end
      click_button '保存する'
    end
    assert_text 'edit test'
  end

  test 'destroy the comment for inquiry' do
    visit_with_auth "/admin/inquiries/#{inquiries(:inquiry2).id}", 'komagata'
    within('.thread-comment:last-child') do
      accept_alert do
        click_button('削除')
      end
    end
    assert_no_text 'inquiryにて削除するコメント'
  end

  test 'comment tab is active after a comment has been posted at inquiry' do
    visit_with_auth "/admin/inquiries/#{inquiries(:inquiry1).id}", 'komagata'
    assert_selector '.a-form-tabs__tab.is-active', text: 'コメント'
    within('.thread-comment-form__form') do
      fill_in('new_comment[description]', with: 'test')
    end
    find('.a-form-tabs__tab', text: 'プレビュー').click
    assert_selector '.a-form-tabs__tab.is-active', text: 'プレビュー'
    click_button 'コメントする'
    assert_selector '.a-form-tabs__tab.is-active', text: 'コメント'
  end

  test 'prevent double submit at inquiry' do
    visit_with_auth "/admin/inquiries/#{inquiries(:inquiry1).id}", 'komagata'
    within('.thread-comment-form__form') do
      fill_in('new_comment[description]', with: 'test')
    end

    # Click button once and verify it becomes disabled
    button = find('#js-shortcut-post-comment', text: 'コメントする')
    button.click

    # Verify the button becomes disabled or not interactable
    prevented = false
    begin
      button.click
      # If we reach here, the button was clickable twice (bad)
    rescue Selenium::WebDriver::Error::ElementClickInterceptedError, Selenium::WebDriver::Error::ElementNotInteractableError
      # This is expected - button should be disabled/not clickable
      prevented = true
    end

    assert prevented, 'Button should be disabled after first click to prevent double submission'
  end

  test 'comment url is copied when click its updated_time at inquiry' do
    visit_with_auth "/admin/inquiries/#{inquiries(:inquiry1).id}", 'komagata'
    # Wait for comments section to load
    if has_css?('#comments.loaded')
      find('#comments.loaded')
    else
      # Fallback: wait for comments section or form to be present
      find('.thread-comment-form, .thread-comment')
    end
    expected_url = current_url + "#comment_#{comments(:comment43).id}"
    click_and_verify_clipboard_copy('.thread-comment__created-at', expected_url, use_first: true)
  end

  test 'text change "see more comments" button by remaining comment amount at inquiry' do
    visit_with_auth "/admin/inquiries/#{inquiries(:inquiry3).id}", 'komagata'

    assert_selector '.a-button.is-lg.is-text.is-block', text: '前のコメント（ 8 / 12 ）'

    find('.a-button.is-lg.is-text.is-block').click
    assert_selector '.a-button.is-lg.is-text.is-block', text: '前のコメント（ 4 ）'

    find('.a-button.is-lg.is-text.is-block').click
    assert_no_selector '.a-button.is-lg.is-text.is-block'
  end

  test 'submit_button is enabled after a post is done at inquiry' do
    visit_with_auth "/admin/inquiries/#{inquiries(:inquiry1).id}", 'komagata'
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

  test 'comments added 8 or within the last 8 at inquiry' do
    visit_with_auth "/admin/inquiries/#{inquiries(:inquiry3).id}", 'komagata'

    assert_text 'テスト用 inquiry3へのコメント。No.20'
    assert_text 'テスト用 inquiry3へのコメント。No.13'
    assert_no_text 'テスト用 inquiry3へのコメント。No.12'

    find('.a-button.is-lg.is-text.is-block').click
    assert_text 'テスト用 inquiry3へのコメント。No.20'
    assert_text 'テスト用 inquiry3へのコメント。No.12'
    assert_text 'テスト用 inquiry3へのコメント。No.5'
    assert_no_text 'テスト用 inquiry3へのコメント。No.4'

    find('.a-button.is-lg.is-text.is-block').click
    assert_text 'テスト用 inquiry3へのコメント。No.20'
    assert_text 'テスト用 inquiry3へのコメント。No.4'
    assert_text 'テスト用 inquiry3へのコメント。No.1'
  end

  test 'clear preview after posting new comment for inquiry' do
    visit_with_auth "/admin/inquiries/#{inquiries(:inquiry1).id}", 'komagata'
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
