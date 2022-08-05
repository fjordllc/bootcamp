# frozen_string_literal: true

require 'application_system_test_case'

class AnnouncementsTest < ApplicationSystemTestCase
  setup do
    @delivery_mode = AbstractNotifier.delivery_mode
    AbstractNotifier.delivery_mode = :normal
  end

  teardown do
    AbstractNotifier.delivery_mode = @delivery_mode
  end

  test 'show link to create new announcement when user is admin' do
    visit_with_auth '/announcements', 'komagata'
    assert_text 'お知らせ作成'
  end

  test "show link to create new announcement when user isn't admin" do
    visit_with_auth '/announcements', 'kimura'
    assert_text 'お知らせ作成'
  end

  test 'show pagination' do
    user = users(:komagata)
    Announcement.delete_all
    26.times do
      Announcement.create(title: 'test', description: 'test', user: user)
    end
    visit_with_auth '/announcements', 'kimura'
    assert_selector 'nav.pagination', count: 2
  end

  test 'show WIP message' do
    user = users(:komagata)
    Announcement.create(title: 'test', description: 'test', user: user, wip: true)
    visit_with_auth '/announcements', 'kimura'
    assert_selector '.a-list-item-badge'
    assert_text 'お知らせ作成中'
  end

  test 'announcement has a comment form ' do
    visit_with_auth "/announcements/#{announcements(:announcement1).id}", 'kimura'
    assert_selector '.thread-comment-form'
  end

  test 'announcement has a copy form when user is admin' do
    visit_with_auth "/announcements/#{announcements(:announcement4).id}", 'komagata'
    click_link 'コピー'

    assert_text 'お知らせをコピーしました。'
  end

  test 'announcement has a copy form when user is author' do
    visit_with_auth "/announcements/#{announcements(:announcement4).id}", 'kimura'
    click_link 'コピー'

    assert_text 'お知らせをコピーしました。'
  end

  test 'users except admin cannot publish an announcement' do
    visit_with_auth new_announcement_path, 'kimura'
    page.assert_no_selector('input[value="作成"]')
  end

  test 'create a new announcement as wip' do
    visit_with_auth new_announcement_path, 'kimura'
    fill_in 'announcement[title]', with: '仮のお知らせ'
    fill_in 'announcement[description]', with: 'まだWIPです。'
    assert_difference 'Announcement.count', 1 do
      click_button 'WIP'
    end
    assert_text 'お知らせをWIPとして保存しました。'
  end

  test 'delete announcement with notification' do
    visit_with_auth '/announcements', 'komagata'
    click_link 'お知らせ作成'
    fill_in 'announcement[title]', with: 'タイトルtest'
    fill_in 'announcement[description]', with: '内容test'

    assert has_no_button? '公開'
    click_button '作成'
    assert_text 'お知らせを作成しました'

    visit_with_auth '/notifications', 'hatsuno'
    assert_text 'お知らせ「タイトルtest」'

    visit_with_auth '/announcements', 'komagata'
    click_on 'タイトルtest'
    accept_confirm do
      click_link '削除'
    end
    assert_text 'お知らせを削除しました'

    visit_with_auth '/notifications', 'hatsuno'
    assert_no_text 'お知らせ「タイトルtest」'
  end

  test "general user can't create announcement" do
    visit_with_auth '/announcements', 'kimura'
    click_link 'お知らせ作成'
    assert has_no_button? '作成'
    assert has_no_button? '公開'
    assert_text 'お知らせを作成しましたら、WIPで保存し、作成したお知らせのコメントから @mentor へ確認・公開の連絡をお願いします。'
  end

  test 'admin user can publish wip announcement' do
    announcement = announcements(:announcement_wip)
    visit_with_auth announcement_path(announcement), 'komagata'
    within '.announcement' do
      click_link '内容修正'
    end
    assert has_no_button? '作成'
    assert has_button? '公開'
    assert_no_text 'お知らせを作成しましたら、WIPで保存し、作成したお知らせのコメントから @mentor へ確認・公開の連絡をお願いします。'
  end

  test "general user can't publish wip announcement" do
    announcement = announcements(:announcement_wip)
    visit_with_auth announcement_path(announcement), 'kimura'
    within '.announcement' do
      click_link '内容修正'
    end
    assert has_no_button? '作成'
    assert has_no_button? '公開'
    assert_text 'お知らせを作成しましたら、WIPで保存し、作成したお知らせのコメントから @mentor へ確認・公開の連絡をお願いします。'
  end

  test 'adimin user can publish submitted announcement' do
    announcement = announcements(:announcement1)
    visit_with_auth announcement_path(announcement), 'komagata'
    within '.announcement' do
      click_link '内容修正'
    end
    assert has_no_button? '作成'
    assert has_button? '公開'
    assert_no_text 'お知らせを作成しましたら、WIPで保存し、作成したお知らせのコメントから @mentor へ確認・公開の連絡をお願いします。'
  end

  test 'general user can publish submitted announcement' do
    announcement = announcements(:announcement1)
    visit_with_auth announcement_path(announcement), 'kimura'
    within '.announcement' do
      click_link '内容修正'
    end
    assert has_no_button? '作成'
    assert has_button? '公開'
    assert_no_text 'お知らせを作成しましたら、WIPで保存し、作成したお知らせのコメントから @mentor へ確認・公開の連絡をお願いします。'
  end

  test 'general user can copy submitted announcement' do
    announcement = announcements(:announcement1)
    visit_with_auth announcement_path(announcement), 'kimura'
    within '.announcement' do
      assert_text 'コピー'
    end
  end

  test 'general user can copy wip announcement' do
    announcement = announcements(:announcement_wip)
    visit_with_auth announcement_path(announcement), 'kimura'
    within '.announcement' do
      assert_text 'コピー'
    end
  end

  test 'show user full_name next to user login_name' do
    visit_with_auth "/announcements/#{announcements(:announcement1).id}", 'kimura'
    assert_text 'komagata (Komagata Masaki)'
  end

  test 'show comment count' do
    visit_with_auth "/announcements/#{announcements(:announcement1).id}", 'kimura'

    fill_in 'new_comment[description]', with: 'コメント数表示のテストです。'
    click_button 'コメントする'

    visit current_path
    assert_selector '#comment_count', text: '2'
  end

  test 'watching is automatically displayed when admin create new announcement' do
    visit_with_auth new_announcement_path, 'komagata'

    fill_in 'announcement[title]', with: 'Watch中になるかのテスト'
    fill_in 'announcement[description]', with: 'お知らせ作成時にWatch中になるかのテストです。'
    click_button '作成'

    assert_text 'お知らせを作成しました。'
    assert_text 'Watch中'
  end

  test 'update_previous_remains_when_conflict_to_update_announcement' do
    announcement = announcements(:announcement_wip)
    visit_with_auth announcement_path(announcement), 'komagata'
    click_link '内容修正'
    fill_in 'announcement[description]', with: '先の人が更新'

    Capybara.session_name = :later
    visit_with_auth announcement_path(announcement), 'kimura'
    click_link '内容修正'
    fill_in 'announcement[description]', with: '後の人が更新'

    Capybara.session_name = :default
    click_button 'WIP'
    assert_text 'お知らせをWIPとして保存しました。'

    Capybara.session_name = :later
    click_button 'WIP'
    assert_text '別の人がお知らせを更新していたので更新できませんでした。'
  end
end
