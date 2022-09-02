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
    visit_with_auth "/admin/users/#{user.id}/edit", 'komagata'
    within 'form[name=user]' do
      fill_in 'user[login_name]', with: 'hatsuno-1'
      click_on '更新する'
    end
    assert_text 'ユーザー情報を更新しました。'
  end

  test 'delete user' do
    user = users(:kimura)
    visit_with_auth admin_users_path(target: 'student_and_trainee'), 'komagata'
    click_on "delete-#{user.id}"
    page.driver.browser.switch_to.alert.accept
    assert_text "#{user.name} さんを削除しました。"
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

  test 'edit user tag' do
    user = users(:kimura)
    visit_with_auth "/admin/users/#{user.id}/edit", 'komagata'
    tag_input = find('.ti-new-tag-input')
    tag_input.set '追加タグ'
    tag_input.native.send_keys :enter
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
      select 'iOSプログラマー', from: 'user[course_id]'
    end
    click_on '更新する'
    assert_equal 'iOSプログラマー', user.reload.course.title
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
end
