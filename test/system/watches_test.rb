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
    find('.watch-toggle').click
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
    find('.watch-toggle').click
    assert_text 'Watch'
    visit_with_auth '/current_user/watches', 'komagata'
    assert_no_text 'injectとreduce'
  end

  test "deleting a comment in a report after removing a watch to the report shouldn't change the watching status" do
    target_report_path = "/reports/#{reports(:report1).id}"
    visit_with_auth target_report_path, 'mentormentaro'
    within('.thread-comment-form__form') do
      fill_in('new_comment[description]', with: 'ウォッチ確認用のtestコメント')
    end
    all('.a-form-tabs__tab.js-tabs__tab')[1].click
    click_button 'コメントする'

    visit '/current_user/watches'
    assert_text '作業週1日目'

    visit target_report_path
    assert_text 'Watch中'
    find('.watch-toggle').click
    assert_text 'Watchを外しました'
    within('.thread-comment:last-child') do
      accept_alert do
        click_button('削除')
      end
    end

    visit '/current_user/watches'
    assert_text 'OS X Mountain Lionをクリーンインストールする'
    assert_no_text '作業週1日目'
  end

  test "updating a comment in a report after removing a watch to the report shouldn't change the watching status" do
    target_report_path = "/reports/#{reports(:report1).id}"
    visit_with_auth target_report_path, 'mentormentaro'
    within('.thread-comment-form__form') do
      fill_in('new_comment[description]', with: 'ウォッチ確認用のtestコメント')
    end
    all('.a-form-tabs__tab.js-tabs__tab')[1].click
    click_button 'コメントする'

    visit '/current_user/watches'
    assert_text '作業週1日目'

    visit target_report_path
    assert_text 'Watch中'
    find('.watch-toggle').click
    assert_text 'Watchを外しました'
    within('.thread-comment:last-child') do
      click_button '編集'
      within('.thread-comment-form__form') do
        fill_in('comment[description]', with: 'ウォッチ確認用のtestコメントを編集')
      end
      click_button '保存する'
    end
    assert_text 'ウォッチ確認用のtestコメントを編集'

    visit '/current_user/watches'
    assert_text 'OS X Mountain Lionをクリーンインストールする'
    assert_no_text '作業週1日目'
  end
end
