# frozen_string_literal: true

require 'application_system_test_case'

class CommentsTest < ApplicationSystemTestCase
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
    within('.thread-comment:nth-child(2)') do
      click_button '編集'
      assert_text 'コメント'
      assert_text 'プレビュー'
    end
  end

  test 'post new comment for report' do
    visit_with_auth "/reports/#{reports(:report1).id}", 'komagata'
    within('.thread-comment-form__form') do
      fill_in('new_comment[description]', with: 'test')
    end
    page.all('.a-form-tabs__tab.js-tabs__tab')[1].click
    assert_text 'test'
    click_button 'コメントする'
    wait_for_vuejs
    assert_text 'test'
  end

  test 'post new comment with mention for report' do
    visit_with_auth "/reports/#{reports(:report1).id}", 'komagata'
    sleep 1
    find('#js-new-comment').set("login_nameの補完テスト: @koma\n")
    click_button 'コメントする'
    wait_for_vuejs
    assert_text 'login_nameの補完テスト: @komagata'
    assert_selector :css, "a[href='/users/komagata']"
  end

  test 'post new comment with mention to mentor for report' do
    visit_with_auth "/reports/#{reports(:report1).id}", 'komagata'
    sleep 1
    find('#js-new-comment').set("login_nameの補完テスト: @men\n")
    click_button 'コメントする'
    wait_for_vuejs
    assert_text 'login_nameの補完テスト: @mentor'
    assert_selector :css, "a[href='/users?target=mentor']"
  end

  test 'post new comment with emoji for report' do
    visit_with_auth "/reports/#{reports(:report1).id}", 'komagata'
    sleep 1
    find('#js-new-comment').set("絵文字の補完テスト: :cat\n")
    click_button 'コメントする'
    wait_for_vuejs
    assert_text '絵文字の補完テスト: 😺'
  end

  test 'post new comment with image for report' do
    visit_with_auth "/reports/#{reports(:report1).id}", 'komagata'
    sleep 1
    find('#js-new-comment').set("![Image](https://example.com/test.png)'")
    click_button 'コメントする'
    wait_for_vuejs
    assert_match '<a href="https://example.com/test.png" target="_blank" rel="noopener noreferrer"><img src="https://example.com/test.png" alt="Image"></a>',
                 page.body
  end

  test 'post new comment with linked image for report' do
    visit_with_auth "/reports/#{reports(:report1).id}", 'komagata'
    sleep 1

    find('#js-new-comment').set('[![Image](https://example.com/test.png)](https://example.com)')
    click_button 'コメントする'
    wait_for_vuejs
    assert_match '<a href="https://example.com"><img src="https://example.com/test.png" alt="Image"></a>', page.body
  end

  test 'edit the comment for report' do
    visit_with_auth "/reports/#{reports(:report3).id}", 'komagata'
    within('.thread-comment:nth-child(2)') do
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
    within('.thread-comment:nth-child(2)') do
      accept_alert do
        click_button('削除')
      end
    end
    assert_no_text 'どういう教材がいいんでしょうかね？'
  end

  test 'post new comment for product' do
    visit_with_auth "/products/#{products(:product1).id}", 'komagata'
    within('.thread-comment-form__form') do
      fill_in('new_comment[description]', with: 'test')
    end
    click_button 'コメントする'
    wait_for_vuejs
    assert_text 'test'
  end

  test 'check preview for product' do
    visit_with_auth "/products/#{products(:product2).id}", 'komagata'
    wait_for_vuejs
    within('.thread-comment-form__form') do
      fill_in('new_comment[description]', with: "1\n2\n3\n4\n5\n6\n7\n8\n9")
    end
    page.all('.a-form-tabs__tab.js-tabs__tab')[1].click
    assert_text "1\n2\n3\n4\n5\n6\n7\n8\n9"
  end

  test 'post new comment for announcement' do
    visit_with_auth "/announcements/#{announcements(:announcement1).id}", 'komagata'
    within('.thread-comment-form__form') do
      fill_in('new_comment[description]', with: 'test')
    end
    page.all('.a-form-tabs__tab.js-tabs__tab')[1].click
    assert_text 'test'
    click_button 'コメントする'
    wait_for_vuejs
    assert_text 'test'
  end

  test 'post new comment for page' do
    visit_with_auth "/pages/#{pages(:page1).id}", 'komagata'
    within('.thread-comment-form__form') do
      fill_in('new_comment[description]', with: 'test')
    end
    page.all('.a-form-tabs__tab.js-tabs__tab')[1].click
    assert_text 'test'
    click_button 'コメントする'
    wait_for_vuejs
    assert_text 'test'
  end

  test 'post new comment for event' do
    visit_with_auth "/events/#{events(:event1).id}", 'komagata'
    within('.thread-comment-form__form') do
      fill_in('new_comment[description]', with: 'test')
    end
    page.all('.a-form-tabs__tab.js-tabs__tab')[1].click
    assert_text 'test'
    click_button 'コメントする'
    wait_for_vuejs
    assert_text 'test'
  end

  test 'comment tab is active after a comment has been posted' do
    visit_with_auth "/reports/#{reports(:report3).id}", 'komagata'
    assert_equal 'コメント', find('.a-form-tabs__tab.is-active').text
    within('.thread-comment-form__form') do
      fill_in('new_comment[description]', with: 'test')
    end
    find('.a-form-tabs__tab', text: 'プレビュー').click
    assert_equal 'プレビュー', find('.a-form-tabs__tab.is-active').text
    click_button 'コメントする'
    wait_for_vuejs
    assert_text 'test'
    assert_equal 'コメント', find('.a-form-tabs__tab.is-active').text
  end

  test 'prevent double submit' do
    visit_with_auth report_path(users(:komagata).reports.first), 'komagata'
    within('.thread-comment-form__form') do
      fill_in('new_comment[description]', with: 'test')
    end
    assert_raises Selenium::WebDriver::Error::ElementClickInterceptedError do
      find('#js-shortcut-post-comment', text: 'コメントする').click.click
    end
  end

  test 'submit_button is enabled after a post is done' do
    visit_with_auth report_path(users(:komagata).reports.first), 'komagata'
    within('.thread-comment-form__form') do
      fill_in('new_comment[description]', with: 'test')
    end
    click_button 'コメントする'
    wait_for_vuejs
    assert_text 'test'
    within('.thread-comment-form__form') do
      fill_in('new_comment[description]', with: 'testtest')
    end
    click_button 'コメントする'
    wait_for_vuejs
    assert_text 'testtest'
  end

  test 'comment url is copied when click its updated_time' do
    visit_with_auth "/reports/#{reports(:report1).id}", 'komagata'
    wait_for_vuejs
    first(:css, '.thread-comment__created-at').click
    # クリップボードを直接読み取る方法がないので、未入力のテキストエリアを経由してクリップボードの値を読み取っている
    # また、Ctrl-Vではペーストできなかったので、かわりにShift-Insertをショートカットキーとして使っている
    # 参考 https://stackoverflow.com/a/57955123/1058763
    find('#js-new-comment').send_keys %i[shift insert]
    clip_text = find('#js-new-comment').value
    assert_equal current_url + "#comment_#{comments(:comment1).id}", clip_text
  end

  test 'suggest mention to mentor' do
    visit_with_auth "/reports/#{reports(:report1).id}", 'komagata'
    sleep 1 # NOTE: ここでsleepしないとテストが失敗する
    find('#js-new-comment').set('@')
    assert_selector 'span.mention', text: 'mentor'
  end

  test 'clicking "see more comments" will display old comments' do
    visit_with_auth product_path(users(:hatsuno).products.first.id), 'komagata'

    assert_no_text '提出物のコメント1です。'
    old_comments = find('.a-button.is-lg.is-text.is-block').text
    assert_text old_comments
    assert_text '提出物のコメント13です。'

    click_button old_comments

    assert_text '提出物のコメント1です。'
    assert_no_text old_comments
    assert_text '提出物のコメント13です。'
  end
end
