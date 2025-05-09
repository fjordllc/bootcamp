# frozen_string_literal: true

require 'application_system_test_case'

class Admin::UsersTest < ApplicationSystemTestCase
  test 'show listing users' do
    visit_with_auth '/admin/users?target=all', 'komagata'
    assert_equal '管理ページ | FBC', title
  end

  test 'show listing students' do
    visit_with_auth '/admin/users', 'komagata'
    assert_equal '管理ページ | FBC', title
  end

  test 'show listing inactive users' do
    visit_with_auth '/admin/users?target=inactive', 'komagata'
    assert_equal '管理ページ | FBC', title
  end

  test 'show listing retired users' do
    visit_with_auth '/admin/users?target=retired', 'komagata'
    assert_equal '管理ページ | FBC', title
  end

  test 'show listing graduated users' do
    visit_with_auth '/admin/users?target=graduate', 'komagata'
    assert_equal '管理ページ | FBC', title
  end

  test 'show listing advisers' do
    visit_with_auth '/admin/users?target=adviser', 'komagata'
    assert_equal '管理ページ | FBC', title
  end

  test 'show listing mentors' do
    visit_with_auth '/admin/users?target=mentor', 'komagata'
    assert_equal '管理ページ | FBC', title
  end

  test 'show listing trainee' do
    visit_with_auth '/admin/users?target=trainee', 'komagata'
    assert_equal '管理ページ | FBC', title
    assert_text 'kensyu（Kensyu Seiko）'
  end

  test 'show listing graduated and office_worker' do
    visit_with_auth '/admin/users?target=graduate&job=office_worker', 'komagata'
    assert_equal '管理ページ | FBC', title
    assert_text 'sotugyou-with-job（卒業 就職済美）'
    assert_no_text 'sotugyou（卒業 太郎）'
  end

  test 'exclude hibernated and retired users from year-end-party email list' do
    visit_with_auth '/admin/users?target=year_end_party', 'komagata'
    assert_equal '管理ページ | FBC', title
    assert_no_text users(:kyuukai).email
    assert_no_text users(:yameo).email
    assert_text users(:kimura).email
  end

  test 'accessed by non-administrative users' do
    user = users(:hatsuno)
    visit_with_auth edit_admin_user_path(user.id), 'kimura'
    assert_text '管理者としてログインしてください'
  end

  test 'an error occurs when updating user-data' do
    user = users(:hatsuno)
    visit_with_auth "/admin/users/#{user.id}/edit", 'komagata'
    within 'form[name=user]' do
      fill_in 'user[login_name]', with: ''
      fill_in 'user[login_name]', with: 'komagata'
      click_on '更新する'
    end
    assert_text 'アカウントはすでに存在します'
  end

  test 'update user' do
    user = users(:hatsuno)

    visit_with_auth "/users/#{user.id}", 'komagata'
    icon_before = find('img.user-profile__user-icon-image', visible: false)
    assert icon_before.native['src'].end_with?('hatsuno.webp')

    visit "/admin/users/#{user.id}/edit"
    within 'form[name=user]' do
      fill_in 'user[login_name]', with: 'hatsuno-1'
      attach_file 'user[avatar]', 'test/fixtures/files/users/avatars/komagata.jpg', make_visible: true
      click_on '更新する'
    end

    assert_text 'ユーザー情報を更新しました。'
    icon_after = find('img.user-profile__user-icon-image', visible: false)
    assert_includes icon_after.native['src'], 'hatsuno'
  end

  test 'update user with company' do
    user = users(:kensyu)
    visit_with_auth "/admin/users/#{user.id}/edit", 'komagata'
    within 'form[name=user]' do
      find('.choices').click
      first('.choices__item', text: 'Lokka Inc.').click
      click_on '更新する'
    end
    assert_text 'ユーザー情報を更新しました。'
    visit "/users/#{user.id}"
    found_value = all('.user-metas__item-value').find { |element| element.text.include?('Lokka Inc.') }
    assert_not_nil(found_value, "Expected to find '.user-metas__item-value' with text 'Lokka Inc.'")
  end

  test 'update advisor with company' do
    user = users(:senpai)
    visit_with_auth "/admin/users/#{user.id}/edit", 'komagata'
    within 'form[name=user]' do
      find('.choices').click
      first('.choices__item', text: 'Lokka Inc.').click
      click_on '更新する'
    end
    assert_text 'ユーザー情報を更新しました。'
    visit "/users/#{user.id}"
    found_value = all('.user-metas__item-value').find { |element| element.text.include?('Lokka Inc.') }
    assert_not_nil(found_value, "Expected to find '.user-metas__item-value' with text 'Lokka Inc.'")
  end

  test 'hide input for retire date when unchecked' do
    user = users(:hatsuno)
    visit_with_auth "/admin/users/#{user.id}/edit", 'komagata'
    assert has_unchecked_field?('retire_checkbox', visible: false)
    assert_no_selector '#user_retired_on'
  end

  test 'show input for retire date when checked' do
    user = users(:hatsuno)
    visit_with_auth "/admin/users/#{user.id}/edit", 'komagata'
    check 'retire_checkbox', allow_label_click: true, visible: false
    assert_selector '#user_retired_on'
  end

  test 'show input for retire date if user is retired' do
    user = users(:yameo)
    visit_with_auth "/admin/users/#{user.id}/edit", 'komagata'
    assert has_checked_field?('retire_checkbox', visible: false)
    assert has_field?('user_retired_on', with: user.retired_on.to_s)
  end

  test 'reset value of retire date when unchecked' do
    user = users(:yameo)
    visit_with_auth "/admin/users/#{user.id}/edit", 'komagata'
    assert has_checked_field?('retire_checkbox', visible: false)
    uncheck 'retire_checkbox', allow_label_click: true, visible: false
    assert has_unchecked_field?('retire_checkbox', visible: false)
    check 'retire_checkbox', allow_label_click: true, visible: false
    assert has_field?('user_retired_on', with: '')
  end

  test 'make user retired' do
    user = users(:hatsuno)
    user.discord_profile.update!(times_id: '987654321987654321')
    date = Date.current
    Discord::Server.stub(:delete_text_channel, true) do
      VCR.use_cassette 'subscription/update' do
        visit_with_auth edit_admin_user_path(user.id), 'komagata'
        check '退会済', allow_label_click: true
        fill_in 'user_retired_on', with: date
        click_on '更新する'
      end
    end
    assert_text 'ユーザー情報を更新しました。'
    assert_equal date, user.reload.retired_on
    assert_nil user.discord_profile.times_id

    assert_requested(:post, "https://api.stripe.com/v1/subscriptions/#{user.subscription_id}") do |req|
      req.body.include?('cancel_at_period_end=true')
    end
  end

  test 'hide input for graduation date when unchecked' do
    user = users(:hatsuno)
    visit_with_auth "/admin/users/#{user.id}/edit", 'komagata'
    assert has_unchecked_field?('graduation_checkbox', visible: false)
    assert_no_selector '#user_graduated_on'
  end

  test 'show input for graduation date when checked' do
    user = users(:hatsuno)
    visit_with_auth "/admin/users/#{user.id}/edit", 'komagata'
    check 'graduation_checkbox', allow_label_click: true, visible: false
    assert_selector '#user_graduated_on'
  end

  test 'show input for graduation date if user is graudated' do
    user = users(:sotugyou)
    visit_with_auth "/admin/users/#{user.id}/edit", 'komagata'
    assert has_checked_field?('graduation_checkbox', visible: false)
    assert has_field?('user_graduated_on', with: user.graduated_on.to_s)
  end

  test 'reset value of graduation date when unchecked' do
    user = users(:sotugyou)
    visit_with_auth "/admin/users/#{user.id}/edit", 'komagata'
    uncheck 'graduation_checkbox', allow_label_click: true, visible: false
    assert has_unchecked_field?('graduation_checkbox', visible: false)
    check 'graduation_checkbox', allow_label_click: true, visible: false
    assert has_field?('user_graduated_on', with: '')
  end

  test 'make user graduated' do
    user = users(:hatsuno)
    date = Date.current
    VCR.use_cassette 'subscription/update' do
      visit_with_auth edit_admin_user_path(user.id), 'komagata'
      check '卒業済', allow_label_click: true
      fill_in 'user_graduated_on', with: date
      click_on '更新する'
    end
    assert_text 'ユーザー情報を更新しました。'
    assert_equal date, user.reload.graduated_on

    assert_requested(:post, "https://api.stripe.com/v1/subscriptions/#{user.subscription_id}") do |req|
      req.body.include?('cancel_at_period_end=true')
    end
  end

  test 'edit user tag' do
    user = users(:kimura)
    visit_with_auth "/admin/users/#{user.id}/edit", 'komagata'
    tag_input = find('.tagify__input')
    tag_input.set ''
    tag_input.set '追加タグ'
    tag_input.native.send_keys :return
    click_on '更新する'
    visit "/admin/users/#{user.id}/edit"
    assert_text '追加タグ'
  end

  test 'does not display advisor in the list of trial period users' do
    start = Time.current - 20.years
    seven_days_later = Time.current + 7.days
    visit_with_auth new_admin_campaign_path, 'komagata'
    within 'form[name=campaign]' do
      fill_in 'campaign[start_at]', with: Time.zone.parse(start.to_s)
      fill_in 'campaign[end_at]', with: Time.zone.parse(seven_days_later.to_s)
      fill_in 'campaign[title]', with: 'テスト用キャンペーン'
      click_button '内容を保存'
    end
    assert_text 'お試し延長を作成しました。'
    visit_with_auth '/admin/users?target=campaign', 'komagata'
    within('.page-body') do
      assert_no_text 'アドバイザー'
    end
  end

  test 'display advisor in lists other than the list of trial period users' do
    start = Time.current - 20.years
    seven_days_later = Time.current + 7.days
    visit_with_auth new_admin_campaign_path, 'komagata'
    within 'form[name=campaign]' do
      fill_in 'campaign[start_at]', with: Time.zone.parse(start.to_s)
      fill_in 'campaign[end_at]', with: Time.zone.parse(seven_days_later.to_s)
      fill_in 'campaign[title]', with: 'テスト用キャンペーン'
      click_button '内容を保存'
    end
    assert_text 'お試し延長を作成しました。'
    visit_with_auth '/admin/users?target=adviser', 'komagata'
    within('.page-body') do
      assert_text 'アドバイザー'
    end
  end

  test 'should not show training end date if user is not trainee' do
    user = users(:kimura)
    visit_with_auth edit_admin_user_path(user.id), 'komagata'
    assert has_unchecked_field?('checkbox_trainee', visible: false)
    assert has_no_field?('user_training_ends_on')
  end

  test 'show training end date if user is trainee' do
    user = users(:kensyu)
    visit_with_auth edit_admin_user_path(user.id), 'komagata'
    assert has_checked_field?('checkbox_trainee', visible: false)
    assert has_field?('user_training_ends_on')
  end

  test 'update value of training end date' do
    user = users(:kensyu)
    training_ends_on = Date.current.next_year
    visit_with_auth edit_admin_user_path(user.id), 'komagata'
    fill_in 'user_training_ends_on', with: training_ends_on
    click_on '更新する'
    visit_with_auth edit_admin_user_path(user.id), 'komagata'
    assert has_field?('user_training_ends_on', with: training_ends_on)
  end

  test 'reset value of training end date when unchecked' do
    user = users(:kensyu)
    visit_with_auth edit_admin_user_path(user.id), 'komagata'
    uncheck 'checkbox_trainee', allow_label_click: true, visible: false
    assert has_unchecked_field?('checkbox_trainee', visible: false)
    check 'checkbox_trainee', allow_label_click: true, visible: false
    assert has_checked_field?('checkbox_trainee', visible: false)
    assert has_field?('user_training_ends_on', with: '')
  end

  test 'admin can change user course' do
    user = users(:kensyu)
    visit_with_auth "/admin/users/#{user.id}/edit", 'machida'
    within 'form[name=user]' do
      select 'iOSエンジニア', from: 'user[course_id]'
    end
    click_on '更新する'
    assert_equal 'iOSエンジニア', user.reload.course.title
  end

  test 'general user cannot change user course' do
    user = users(:kensyu)
    visit_with_auth "/admin/users/#{user.id}/edit", 'kimura'
    assert_current_path('/')
    assert_text '管理者としてログインしてください'
  end

  test 'administrator cannot update profiles of general users' do
    user = users(:kimura)
    visit_with_auth "/admin/users/#{user.id}/edit", 'komagata'
    assert_no_text 'プロフィール'
    assert_no_text 'プロフィール画像'
    assert_no_text 'プロフィール名'
    assert_no_text 'プロフィール文'
  end

  test 'administrator can update profiles of mentors' do
    user = users(:machida)
    visit_with_auth "/admin/users/#{user.id}/edit", 'komagata'
    assert_text 'プロフィール'
    assert_text 'プロフィール画像'
    assert_text 'プロフィール名'
    assert_text 'プロフィール文'
  end

  test 'administrator can set user’s special user attribute to mentor' do
    user = users(:advijirou)
    visit_with_auth "/admin/users/#{user.id}/edit", 'komagata'
    assert_no_text 'メンター紹介用公開プロフィール'
    check 'checkbox_mentor', allow_label_click: true, visible: false
    assert has_checked_field?('checkbox_mentor', visible: false)
    click_on '更新する'
    assert_text 'ユーザー情報を更新しました'
    visit_with_auth "/admin/users/#{user.id}/edit", 'komagata'
    assert_text 'メンター紹介用公開プロフィール'
  end

  test 'administrator can update hide profile of mentor' do
    user = users(:mentormentaro)
    visit_with_auth "/admin/users/#{user.id}/edit", 'komagata'
    assert_text 'メンター紹介用公開プロフィール'
    assert_no_checked_field('user_hide_mentor_profile', visible: false)
    check 'user_hide_mentor_profile', allow_label_click: true, visible: false
    assert has_checked_field?('user_hide_mentor_profile', visible: false)
    click_on '更新する'
    assert_text 'ユーザー情報を更新しました'
    visit_with_auth "/admin/users/#{user.id}/edit", 'komagata'
    assert has_checked_field?('user_hide_mentor_profile', visible: false)
  end

  test 'administrator can set skipped_practice of general users' do
    user = users(:kensyu)
    visit_with_auth "/admin/users/#{user.id}/edit", 'komagata'
    assert_text 'UNIX (1/9)', normalize_ws: true
    check 'UNIX', allow_label_click: true, visible: false
    check 'Terminalの基礎を覚える', allow_label_click: true, visible: false
    click_on '更新する'
    assert_text 'ユーザー情報を更新しました'
    visit_with_auth "/admin/users/#{user.id}/edit", 'komagata'
    assert_text 'UNIX (2/9)', normalize_ws: true
  end
end
