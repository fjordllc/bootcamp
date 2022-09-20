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
    within('.thread-comment:first-child') do
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
    all('.a-form-tabs__tab.js-tabs__tab')[1].click
    assert_text 'test'
    click_button 'コメントする'
    assert_text 'test'
  end

  test 'post new comment with mention for report' do
    visit_with_auth "/reports/#{reports(:report1).id}", 'komagata'
    find('#comments.loaded', wait: 10)

    Timeout.timeout(Capybara.default_max_wait_time) do
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
    find('#comments.loaded', wait: 10)

    Timeout.timeout(Capybara.default_max_wait_time) do
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
    find('#comments.loaded', wait: 10)

    Timeout.timeout(Capybara.default_max_wait_time) do
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
    find('#comments.loaded', wait: 10)
    find('#js-new-comment').set('画像付きで説明します。 ![Image](https://example.com/test.png)')
    click_button 'コメントする'
    assert_text '画像付きで説明します。'
    assert_match '<a href="https://example.com/test.png" target="_blank" rel="noopener noreferrer"><img src="https://example.com/test.png" alt="Image"></a>',
                 page.body
  end

  test 'post new comment with linked image for report' do
    visit_with_auth "/reports/#{reports(:report1).id}", 'komagata'
    find('#comments.loaded', wait: 10)
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

  test 'post new comment for product' do
    visit_with_auth "/products/#{products(:product1).id}", 'komagata'
    within('.thread-comment-form__form') do
      fill_in('new_comment[description]', with: 'test')
    end
    click_button 'コメントする'
    assert_text 'test'
  end

  test 'check preview for product' do
    visit_with_auth "/products/#{products(:product2).id}", 'komagata'
    within('.thread-comment-form__form') do
      fill_in('new_comment[description]', with: "1\n2\n3\n4\n5\n6\n7\n8\n9")
    end
    all('.a-form-tabs__tab.js-tabs__tab')[1].click
    assert_text "1\n2\n3\n4\n5\n6\n7\n8\n9"
  end

  test 'post new comment for announcement' do
    visit_with_auth "/announcements/#{announcements(:announcement1).id}", 'komagata'
    within('.thread-comment-form__form') do
      fill_in('new_comment[description]', with: 'test')
    end
    all('.a-form-tabs__tab.js-tabs__tab')[1].click
    assert_text 'test'
    click_button 'コメントする'
    assert_text 'test'
  end

  test 'post new comment for page' do
    visit_with_auth "/pages/#{pages(:page1).id}", 'komagata'
    within('.thread-comment-form__form') do
      fill_in('new_comment[description]', with: 'test')
    end
    all('.a-form-tabs__tab.js-tabs__tab')[1].click
    assert_text 'test'
    click_button 'コメントする'
    assert_text 'test'
  end

  test 'post new comment for event' do
    visit_with_auth "/events/#{events(:event1).id}", 'komagata'
    within('.thread-comment-form__form') do
      fill_in('new_comment[description]', with: 'test')
    end
    all('.a-form-tabs__tab.js-tabs__tab')[1].click
    assert_text 'test'
    click_button 'コメントする'
    assert_text 'test'
  end

  test 'comment tab is active after a comment has been posted' do
    visit_with_auth "/reports/#{reports(:report3).id}", 'komagata'
    assert_selector '.a-form-tabs__tab.is-active', text: 'コメント'
    within('.thread-comment-form__form') do
      fill_in('new_comment[description]', with: 'test')
    end
    find('.a-form-tabs__tab', text: 'プレビュー').click
    assert_selector '.a-form-tabs__tab.is-active', text: 'プレビュー'
    click_button 'コメントする'
    assert_selector '.a-form-tabs__tab.is-active', text: 'コメント'
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
    assert_text 'test'
    within('.thread-comment-form__form') do
      fill_in('new_comment[description]', with: 'testtest')
    end
    click_button 'コメントする'
    assert_text 'testtest'
  end

  test 'comment url is copied when click its updated_time' do
    visit_with_auth "/reports/#{reports(:report1).id}", 'komagata'
    find('#comments.loaded', wait: 10)
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

  test 'suggest mention to mentor' do
    visit_with_auth "/reports/#{reports(:report1).id}", 'komagata'
    find('#comments.loaded', wait: 10)
    Timeout.timeout(Capybara.default_max_wait_time) do
      find('#js-new-comment').set('@') until has_selector?('span.mention', wait: false)
    end
    assert_selector 'span.mention', text: 'mentor'
  end

  test 'text change "see more comments" button by remaining comment amount' do
    visit_with_auth product_path(users(:hatsuno).products.first.id), 'komagata'

    assert_selector '.a-button.is-lg.is-text.is-block', text: '前のコメント（ 8 / 12 ）'

    find('.a-button.is-lg.is-text.is-block').click
    assert_selector '.a-button.is-lg.is-text.is-block', text: '前のコメント（ 4 ）'

    find('.a-button.is-lg.is-text.is-block').click
    assert_no_selector '.a-button.is-lg.is-text.is-block'
  end

  test 'comments added 8 or within the last 8' do
    visit_with_auth product_path(users(:hatsuno).products.first.id), 'komagata'

    assert_text '提出物のコメント20です'
    assert_text '提出物のコメント13です。'
    assert_no_text '提出物のコメント12です。'

    find('.a-button.is-lg.is-text.is-block').click
    assert_text '提出物のコメント20です'
    assert_text '提出物のコメント12です。'
    assert_text '提出物のコメント5です。'
    assert_no_text '提出物のコメント4です。'

    find('.a-button.is-lg.is-text.is-block').click
    assert_text '提出物のコメント20です'
    assert_text '提出物のコメント4です。'
    assert_text '提出物のコメント1です。'
  end

  test 'clear preview after posting new comment for report' do
    visit_with_auth "/reports/#{reports(:report1).id}", 'komagata'
    find('#js-new-comment').set('test')
    click_button 'コメントする'
    assert_text 'test'
    find('.a-form-tabs__tab.js-tabs__tab', text: 'プレビュー').click
    assert_selector '.a-form-tabs__tab.is-active', text: 'プレビュー'
    within('#new-comment-preview') do
      assert_no_text :all, 'test'
    end
  end

  test 'when mentor confirm a product with comment' do
    unconfirmed_product = products(:product1)
    visit_with_auth product_url(unconfirmed_product), 'machida'
    click_button '担当する'
    assert_button '担当から外れる'

    accept_confirm do
      fill_in 'new_comment[description]', with: 'comment test'
      click_button '確認OKにする'
    end
    assert_text '提出物を確認済みにしました'
    assert_text 'comment test'
  end

  test 'when mentor confirm unassigned product with comment' do
    unassigned_product = products(:product1)
    visit_with_auth product_url(unassigned_product), 'machida'
    assert_button '担当する'

    accept_confirm do
      fill_in 'new_comment[description]', with: 'comment test'
      click_button '確認OKにする'
    end
    assert_text '提出物を確認済みにしました'
    assert_text 'comment test'
  end

  test 'when mentor confirm a report with comment' do
    visit_with_auth "/reports/#{reports(:report2).id}", 'machida'
    assert_text '確認OKにする'
    within('.thread-comment-form__form') do
      fill_in('new_comment[description]', with: 'comment test')
    end
    click_button '確認OKにする'

    assert_text '日報を確認済みにしました'
    assert_text 'comment test'
  end

  test ' company logo appear when adviser belongs to the company post comment ' do
    visit_with_auth "/reports/#{reports(:report1).id}", 'senpai'
    within('.thread-comment-form__form') do
      fill_in('new_comment[description]', with: 'test')
    end
    all('.a-form-tabs__tab.js-tabs__tab')[1].click
    assert_text 'test'
    click_button 'コメントする'
    assert_text 'test'
    assert find('img.thread-comment__company-logo')['src'].include?('2.png')
  end
end
