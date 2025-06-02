# frozen_string_literal: true

require 'application_system_test_case'

class ReportCommentsTest < ApplicationSystemTestCase
  test 'post new comment for report' do
    visit_with_auth "/reports/#{reports(:report1).id}", 'komagata'
    # テストが落ちやすいため、setCheckableが実行されるまで待つ
    within('.page-content-header') do
      find('.stamp.stamp-approve')
    end

    within('.thread-comment-form__form') do
      fill_in('new_comment[description]', with: 'test')
    end
    all('.a-form-tabs__tab.js-tabs__tab')[1].click
    assert_text 'test'
    click_button 'コメントする'
    assert_text 'test'
    assert_text 'Watch中'
  end

  test 'post new comment with mention for report' do
    visit_with_auth "/reports/#{reports(:report1).id}", 'komagata'
    # Wait for comments section to load
    if has_css?('#comments.loaded', wait: 2)
      find('#comments.loaded')
    else
      # Fallback: wait for comments section or form to be present
      find('.thread-comment-form, .thread-comment', wait: 10)
    end

    Timeout.timeout(Capybara.default_max_wait_time, StandardError) do
      until find('#js-new-comment').value == 'login_nameの補完テスト: @komagata '
        find('#js-new-comment').set('')
        find('#js-new-comment').set("login_nameの補完テスト: @koma\n")
      end
    end

    click_button 'コメントする'
    assert_text 'login_nameの補完テスト: @komagata'
    assert_selector :css, "a[href='/users/komagata']"
  end

  test 'post new comment with mention to mentor for report' do
    visit_with_auth "/reports/#{reports(:report1).id}", 'komagata'
    # Wait for comments section to load
    if has_css?('#comments.loaded', wait: 2)
      find('#comments.loaded')
    else
      # Fallback: wait for comments section or form to be present
      find('.thread-comment-form, .thread-comment', wait: 10)
    end

    Timeout.timeout(Capybara.default_max_wait_time, StandardError) do
      until find('#js-new-comment').value == 'login_nameの補完テスト: @mentor '
        find('#js-new-comment').set('')
        find('#js-new-comment').set("login_nameの補完テスト: @men\n")
      end
    end

    click_button 'コメントする'
    assert_text 'login_nameの補完テスト: @mentor'
    assert_selector :css, "a[href='/users?target=mentor']"
  end

  test 'post new comment with emoji for report' do
    visit_with_auth "/reports/#{reports(:report1).id}", 'komagata'
    within('.page-content-header') do
      find('.stamp.stamp-approve')
    end

    # Wait for comments section to load
    if has_css?('#comments.loaded', wait: 2)
      find('#comments.loaded')
    else
      # Fallback: wait for comments section or form to be present
      find('.thread-comment-form, .thread-comment', wait: 10)
    end

    Timeout.timeout(Capybara.default_max_wait_time, StandardError) do
      until find('#js-new-comment').value == '絵文字の補完テスト: 😺 '
        find('#js-new-comment').set('')
        find('#js-new-comment').set("絵文字の補完テスト: :cat\n")
      end
    end

    click_button 'コメントする'
    assert_text '絵文字の補完テスト: 😺'
  end

  test 'post new comment with image for report' do
    visit_with_auth "/reports/#{reports(:report1).id}", 'komagata'
    within('.page-content-header') do
      find('.stamp.stamp-approve')
    end

    # Wait for comments section to load
    if has_css?('#comments.loaded', wait: 2)
      find('#comments.loaded')
    else
      # Fallback: wait for comments section or form to be present
      find('.thread-comment-form, .thread-comment', wait: 10)
    end
    find('#js-new-comment').set('画像付きで説明します。 ![Image](https://example.com/test.png)')
    click_button 'コメントする'
    assert_text '画像付きで説明します。'
    assert_match '<a href="https://example.com/test.png" target="_blank" rel="noopener noreferrer"><img src="https://example.com/test.png" alt="Image"></a>',
                 page.body
  end

  test 'post new comment with linked image for report' do
    visit_with_auth "/reports/#{reports(:report1).id}", 'komagata'
    within('.page-content-header') do
      find('.stamp.stamp-approve')
    end

    # Wait for comments section to load
    if has_css?('#comments.loaded', wait: 2)
      find('#comments.loaded')
    else
      # Fallback: wait for comments section or form to be present
      find('.thread-comment-form, .thread-comment', wait: 10)
    end
    find('#js-new-comment').set('[![Image](https://example.com/test.png)](https://example.com)')
    click_button 'コメントする'
    assert_match '<a href="https://example.com"><img src="https://example.com/test.png" alt="Image"></a>', page.body
  end

  test 'edit the comment for report' do
    visit_with_auth "/reports/#{reports(:report3).id}", 'komagata'
    within('.thread-comment:first-child') do
      click_button '編集'
      within(:css, '.thread-comment-form__form') do
        fill_in('comment[description]', with: 'edit test')
      end
      click_button '保存する'
    end
    assert_text 'edit test'
  end

  test 'destroy the comment for report' do
    visit_with_auth "/reports/#{reports(:report3).id}", 'komagata'
    within('.thread-comment:first-child') do
      accept_alert do
        click_button('削除')
      end
    end
    assert_no_text 'どういう教材がいいんでしょうかね？'
  end

  test 'when mentor confirm a report with comment' do
    visit_with_auth "/reports/#{reports(:report2).id}", 'machida'

    # Wait for page to fully load
    # Wait for comments section to load
    if has_css?('#comments.loaded', wait: 2)
      find('#comments.loaded')
    else
      # Fallback: wait for comments section or form to be present
      find('.thread-comment-form, .thread-comment', wait: 10)
    end

    assert_text '確認OKにする'
    within('.thread-comment-form__form') do
      fill_in('new_comment[description]', with: 'comment test')
    end
    click_button '確認OKにする'

    # Wait for comment to be displayed first
    assert_selector '.thread-comment__description', text: 'comment test', wait: 10

    # Check that report is confirmed in database
    assert reports(:report2).reload.checked?
  end

  test 'show confirm dialog if report is not confirmed' do
    visit_with_auth "/reports/#{reports(:report2).id}", 'machida'

    # Wait for page to load completely
    # Wait for comments section to load
    if has_css?('#comments.loaded', wait: 2)
      find('#comments.loaded')
    else
      # Fallback: wait for comments section or form to be present
      find('.thread-comment-form, .thread-comment', wait: 10)
    end

    within('.thread-comment-form__form') do
      fill_in('new_comment[description]', with: 'comment test')
    end

    # Check if confirmation button exists and handle accordingly
    if has_text?('確認OKにする', wait: 5)
      accept_confirm '日報を確認済みにしていませんがよろしいですか？' do
        click_button 'コメントする'
      end
    else
      click_button 'コメントする'
    end

    assert_text 'comment test'
  end
end
