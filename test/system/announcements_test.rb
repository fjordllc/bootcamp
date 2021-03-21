# frozen_string_literal: true

require 'application_system_test_case'

class AnnouncementsTest < ApplicationSystemTestCase
  test 'show link to create new announcement when user is admin' do
    login_user 'komagata', 'testtest'
    visit '/announcements'
    assert_text 'お知らせ作成'
  end

  test "show link to create new announcement when user isn't admin" do
    login_user 'kimura', 'testtest'
    visit '/announcements'
    assert_text 'お知らせ作成'
  end

  test 'show pagination' do
    login_user 'kimura', 'testtest'
    user = users(:komagata)
    Announcement.delete_all
    26.times do
      Announcement.create(title: 'test', description: 'test', user: user)
    end
    visit '/announcements'
    assert_selector 'nav.pagination', count: 2
  end

  test 'show WIP message' do
    login_user 'kimura', 'testtest'
    user = users(:komagata)
    Announcement.create(title: 'test', description: 'test', user: user, wip: true)
    visit '/announcements'
    assert_selector '.thread-list-item__header-icon'
    assert_text 'お知らせ作成中'
  end

  test 'show new action link' do
    login_user 'hatsuno', 'testtest'
    user = users(:hatsuno)
    Announcement.create(title: 'test', description: 'test', user: user, wip: true)
    visit '/announcements'
    assert_selector '.thread-list-item__actions-link'
  end

  test 'announcement has a comment form ' do
    login_user 'kimura', 'testtest'
    visit "/announcements/#{announcements(:announcement1).id}"
    assert_selector '.thread-comment-form'
  end

  test 'announcement has a copy form when user is admin' do
    login_user 'komagata', 'testtest'
    visit "/announcements/#{announcements(:announcement4).id}"
    click_link 'コピー'

    assert_text 'お知らせをコピーしました。'
  end

  test 'announcement has a copy form when user is author' do
    login_user 'kimura', 'testtest'
    visit "/announcements/#{announcements(:announcement4).id}"
    click_link 'コピー'

    assert_text 'お知らせをコピーしました。'
  end

  test 'users except admin cannot publish an announcement' do
    login_user 'kimura', 'testtest'
    visit new_announcement_path
    page.assert_no_selector('input[value="作成"]')
  end

  test 'create a new announcement as wip' do
    login_user 'kimura', 'testtest'
    visit new_announcement_path
    fill_in 'announcement[title]', with: '仮のお知らせ'
    fill_in 'announcement[description]', with: 'まだWIPです。'
    assert_difference 'Announcement.count', 1 do
      click_button 'WIP'
    end
    assert_text 'お知らせをWIPとして保存しました。'
  end

  test 'delete announcement with notification' do
    login_user 'komagata', 'testtest'
    visit '/announcements'
    click_link 'お知らせ作成'
    fill_in 'announcement[title]', with: 'タイトルtest'
    fill_in 'announcement[description]', with: '内容test'

    click_button '作成'
    assert_text 'お知らせを作成しました'

    login_user 'hatsuno', 'testtest'
    visit '/notifications'
    assert_text 'komagataさんからお知らせです。'

    login_user 'komagata', 'testtest'
    visit '/announcements'
    click_on 'タイトルtest'
    accept_confirm do
      click_link '削除'
    end
    assert_text 'お知らせを削除しました'

    login_user 'hatsuno', 'testtest'
    visit '/notifications'
    assert_no_text 'komagataさんからお知らせです。'
  end

  test 'announcement notification receive only active users' do
    login_user 'machida', 'testtest'
    visit '/announcements'
    click_link 'お知らせ作成'
    fill_in 'announcement[title]', with: '現役生にのみお知らせtest'
    fill_in 'announcement[description]', with: '内容test'
    choose '現役生にのみお知らせ', visible: false

    click_button '作成'
    assert_text 'お知らせを作成しました'

    login_user 'komagata', 'testtest'
    visit '/notifications'
    assert_text 'machidaさんからお知らせです。'

    login_user 'kimura', 'testtest'
    visit '/notifications'
    assert_text 'machidaさんからお知らせです。'

    login_user 'sotugyou', 'testtest'
    visit '/notifications'
    assert_no_text 'machidaさんからお知らせです。'

    login_user 'advijirou', 'testtest'
    visit '/notifications'
    assert_no_text 'machidaさんからお知らせです。'

    login_user 'yameo', 'testtest'
    visit '/notifications'
    assert_no_text 'machidaさんからお知らせです。'

    login_user 'yamada', 'testtest'
    visit '/notifications'
    assert_no_text 'machidaさんからお知らせです。'

    login_user 'kensyu', 'testtest'
    visit '/notifications'
    assert_no_text 'machidaさんからお知らせです。'
  end

  test 'announcement notifications are only recived by job seekers' do
    login_user 'machida', 'testtest'
    visit '/announcements'
    click_link 'お知らせ作成'
    fill_in 'announcement[title]', with: '就活希望者のみお知らせします'
    fill_in 'announcement[description]', with: '合同説明会をやるのでぜひいらしてください！'
    choose '就職希望者にのみお知らせ', visible: false

    click_button '作成'
    assert_text 'お知らせを作成しました'

    login_user 'komagata', 'testtest'
    visit '/notifications'
    assert_text 'machidaさんからお知らせです。'

    login_user 'jobseeker', 'testtest'
    visit '/notifications'
    assert_text 'machidaさんからお知らせです。'

    login_user 'kimura', 'testtest'
    visit '/notifications'
    assert_no_text 'machidaさんからお知らせです。'
  end
end
