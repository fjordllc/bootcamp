# frozen_string_literal: true

require 'application_system_test_case'

class AnnouncementsTest < ApplicationSystemTestCase
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
    assert_selector '.thread-list-item-title__icon'
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

    click_button '作成'
    assert_text 'お知らせを作成しました'

    visit_with_auth '/notifications', 'hatsuno'
    assert_text 'komagataさんからお知らせです。'

    visit_with_auth '/announcements', 'komagata'
    click_on 'タイトルtest'
    accept_confirm do
      click_link '削除'
    end
    assert_text 'お知らせを削除しました'

    visit_with_auth '/notifications', 'hatsuno'
    assert_no_text 'komagataさんからお知らせです。'
  end

  test 'announcement notification receive only active users' do
    visit_with_auth '/announcements', 'machida'
    click_link 'お知らせ作成'
    fill_in 'announcement[title]', with: '現役生にのみお知らせtest'
    fill_in 'announcement[description]', with: '内容test'
    choose '現役生にのみお知らせ', visible: false

    click_button '作成'
    assert_text 'お知らせを作成しました'

    visit_with_auth '/notifications', 'komagata'
    assert_text 'machidaさんからお知らせです。'

    visit_with_auth '/notifications', 'kimura'
    assert_text 'machidaさんからお知らせです。'

    visit_with_auth '/notifications', 'sotugyou'
    assert_no_text 'machidaさんからお知らせです。'

    visit_with_auth '/notifications', 'advijirou'
    assert_no_text 'machidaさんからお知らせです。'

    visit_with_auth '/notifications', 'yameo'
    assert_no_text 'machidaさんからお知らせです。'

    visit_with_auth '/notifications', 'yamada'
    assert_no_text 'machidaさんからお知らせです。'

    visit_with_auth '/notifications', 'kensyu'
    assert_no_text 'machidaさんからお知らせです。'
  end

  test 'announcement notifications are only recived by job seekers' do
    visit_with_auth '/announcements', 'machida'
    click_link 'お知らせ作成'
    fill_in 'announcement[title]', with: '就活希望者のみお知らせします'
    fill_in 'announcement[description]', with: '合同説明会をやるのでぜひいらしてください！'
    choose '就職希望者にのみお知らせ', visible: false

    click_button '作成'
    assert_text 'お知らせを作成しました'

    visit_with_auth '/notifications', 'komagata'
    assert_text 'machidaさんからお知らせです。'

    visit_with_auth '/notifications', 'jobseeker'
    assert_text 'machidaさんからお知らせです。'

    visit_with_auth '/notifications', 'kimura'
    assert_no_text 'machidaさんからお知らせです。'
  end

  test "general user can't edit submitted announcement" do
    announcement = announcements(:announcement1)
    visit_with_auth announcement_path(announcement), 'kimura'
    within '.thread__inner' do
      assert_no_text '内容修正'
    end
  end

  test 'general user can edit wip announcement' do
    announcement = announcements(:announcement_wip)
    visit_with_auth announcement_path(announcement), 'kimura'
    within '.thread__inner' do
      assert_text '内容修正'
    end
  end

  test 'general user can copy submitted announcement' do
    announcement = announcements(:announcement1)
    visit_with_auth announcement_path(announcement), 'kimura'
    within '.thread__inner' do
      assert_text 'コピー'
    end
  end

  test 'general user can copy wip announcement' do
    announcement = announcements(:announcement_wip)
    visit_with_auth announcement_path(announcement), 'kimura'
    within '.thread__inner' do
      assert_text 'コピー'
    end
  end

  test 'show user full_name next to user login_name' do
    visit_with_auth "/announcements/#{announcements(:announcement1).id}", 'kimura'
    assert_text 'komagata (Komagata Masaki)'
  end

  test 'show comment count' do
    visit_with_auth "/announcements/#{announcements(:announcement1).id}", 'kimura'
    assert_text "コメント（\n1\n）"

    fill_in 'new_comment[description]', with: 'コメント数表示のテストです。'
    click_button 'コメントする'
    wait_for_vuejs

    visit current_path
    assert_text "コメント（\n2\n）"
  end

  test 'watching is automatically displayed when admin create new announcement' do
    visit_with_auth new_announcement_path, 'komagata'

    fill_in 'announcement[title]', with: 'Watch中になるかのテスト'
    fill_in 'announcement[description]', with: 'お知らせ作成時にWatch中になるかのテストです。'
    click_button '作成'

    assert_text 'お知らせを作成しました。'
    assert_text 'Watch中'
  end
end
