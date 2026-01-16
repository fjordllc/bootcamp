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

    wait_for_comments

    fill_in_with_autocomplete(
      '#js-new-comment',
      input_text: "login_nameの補完テスト: @koma\n",
      expected_value: 'login_nameの補完テスト: @komagata '
    )

    click_button 'コメントする'
    assert_text 'login_nameの補完テスト: @komagata'
    assert_selector :css, "a[href='/users/komagata']"
  end

  test 'post new comment with mention to mentor for report' do
    visit_with_auth "/reports/#{reports(:report1).id}", 'komagata'

    wait_for_comments

    fill_in_with_autocomplete(
      '#js-new-comment',
      input_text: "login_nameの補完テスト: @men\n",
      expected_value: 'login_nameの補完テスト: @mentor '
    )

    click_button 'コメントする'
    assert_text 'login_nameの補完テスト: @mentor'
    assert_selector :css, "a[href='/users?target=mentor']"
  end

  test 'post new comment with emoji for report' do
    visit_with_auth "/reports/#{reports(:report1).id}", 'komagata'
    within('.page-content-header') do
      find('.stamp.stamp-approve')
    end

    wait_for_comments

    fill_in_with_autocomplete(
      '#js-new-comment',
      input_text: "絵文字の補完テスト: :cat\n",
      expected_value: '絵文字の補完テスト: 😺 '
    )

    click_button 'コメントする'
    assert_text '絵文字の補完テスト: 😺'
  end

  test 'post new comment with image for report' do
    visit_with_auth "/reports/#{reports(:report1).id}", 'komagata'
    within('.page-content-header') do
      find('.stamp.stamp-approve')
    end

    wait_for_comments

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

    wait_for_comments

    find('#js-new-comment').set('[![Image](https://example.com/test.png)](https://example.com)')
    click_button 'コメントする'
    assert_match '<a href="https://example.com" target="_blank" rel="noopener"><img src="https://example.com/test.png" alt="Image"></a>', page.body
  end

  test 'edit the comment for report' do
    visit_with_auth "/reports/#{reports(:report3).id}", 'komagata'

    first('button', text: '編集').click
    fill_in 'comment[description]', with: 'edit test'
    click_button '保存する'

    assert_text 'edit test'
    assert_no_text 'どういう教材がいいんでしょうかね？'
  end

  test 'destroy the comment for report' do
    visit_with_auth "/reports/#{reports(:report3).id}", 'komagata'

    assert_selector '.thread-comment:first-child'

    accept_alert do
      page.find('button', text: '削除', match: :first).click
    end

    assert_no_text 'どういう教材がいいんでしょうかね？'
  end

  test 'mentor can edit other user comment for report' do
    visit_with_auth "/reports/#{reports(:report3).id}", 'mentormentaro'

    # Wait for comments to load
    assert_selector '.thread-comment:first-child'

    # Find komagata's comment and click edit button
    within(all('.thread-comment').find { |comment| comment.text.include?('どういう教材がいいんでしょうかね？') }) do
      click_button '編集'
    end

    fill_in 'comment[description]', with: 'mentor edited this comment'
    click_button '保存する'

    assert_text 'mentor edited this comment'
    assert_no_text 'どういう教材がいいんでしょうかね？'
  end

  test 'admin can destroy other user comment for report' do
    visit_with_auth "/reports/#{reports(:report3).id}", 'komagata'

    assert_selector '.thread-comment:first-child'

    # Find machida's comment and delete it
    accept_alert do
      within(all('.thread-comment').find { |comment| comment.text.include?('https://github.com/fjordllc/csstutorial/tree/master') }) do
        click_button '削除'
      end
    end

    assert_no_text 'https://github.com/fjordllc/csstutorial/tree/master とかですかねー。'
  end

  test 'regular user cannot see edit/delete buttons for other user comment' do
    visit_with_auth "/reports/#{reports(:report3).id}", 'kimura'

    # Wait for comments to load
    assert_selector '.thread-comment:first-child'

    # Check that edit/delete buttons are not visible for other users' comments
    within(all('.thread-comment').find { |comment| comment.text.include?('どういう教材がいいんでしょうかね？') }) do
      assert_no_button '編集'
      assert_no_button '削除'
    end

    within(all('.thread-comment').find { |comment| comment.text.include?('https://github.com/fjordllc/csstutorial/tree/master') }) do
      assert_no_button '編集'
      assert_no_button '削除'
    end
  end

  test 'when mentor confirm a report with comment' do
    visit_with_auth "/reports/#{reports(:report2).id}", 'machida'

    # Wait for page to fully load
    if has_css?('#comments.loaded')
      find('#comments.loaded')
    else
      find('.thread-comment-form, .thread-comment')
    end

    assert_text '確認OKにする'
    within('.thread-comment-form__form') do
      fill_in('new_comment[description]', with: 'comment test')
    end
    click_button '確認OKにする'

    # Wait for comment to be displayed first
    assert_selector '.thread-comment__description', text: 'comment test'
    assert_text '確認済'
  end

  test 'show confirm dialog if report is not confirmed' do
    visit_with_auth "/reports/#{reports(:report2).id}", 'machida'

    wait_for_comments

    within('.thread-comment-form__form') do
      fill_in('new_comment[description]', with: 'comment test')
    end

    if has_text?('確認OKにする')
      accept_confirm '日報を確認済みにしていませんがよろしいですか？' do
        click_button 'コメントする'
      end
    else
      click_button 'コメントする'
    end

    assert_text 'comment test'
  end
end
