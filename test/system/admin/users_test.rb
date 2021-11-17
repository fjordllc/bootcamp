# frozen_string_literal: true

require 'application_system_test_case'

class Admin::UsersTest < ApplicationSystemTestCase
  test 'show listing users' do
    visit_with_auth '/admin/users?target=all', 'komagata'
    assert_equal '管理ページ | FJORD BOOT CAMP（フィヨルドブートキャンプ）', title
  end

  test 'show listing students' do
    visit_with_auth '/admin/users', 'komagata'
    assert_equal '管理ページ | FJORD BOOT CAMP（フィヨルドブートキャンプ）', title
  end

  test 'show listing inactive users' do
    visit_with_auth '/admin/users?target=inactive', 'komagata'
    assert_equal '管理ページ | FJORD BOOT CAMP（フィヨルドブートキャンプ）', title
  end

  test 'show listing retired users' do
    visit_with_auth '/admin/users?target=retired', 'komagata'
    assert_equal '管理ページ | FJORD BOOT CAMP（フィヨルドブートキャンプ）', title
  end

  test 'show listing graduated users' do
    visit_with_auth '/admin/users?target=graduate', 'komagata'
    assert_equal '管理ページ | FJORD BOOT CAMP（フィヨルドブートキャンプ）', title
  end

  test 'show listing advisers' do
    visit_with_auth '/admin/users?target=adviser', 'komagata'
    assert_equal '管理ページ | FJORD BOOT CAMP（フィヨルドブートキャンプ）', title
  end

  test 'show listing mentors' do
    visit_with_auth '/admin/users?target=mentor', 'komagata'
    assert_equal '管理ページ | FJORD BOOT CAMP（フィヨルドブートキャンプ）', title
  end

  test 'show listing trainee' do
    visit_with_auth '/admin/users?target=trainee', 'komagata'
    assert_equal '管理ページ | FJORD BOOT CAMP（フィヨルドブートキャンプ）', title
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
    check 'retire_checkbox', allow_label_click: true
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
    uncheck 'retire_checkbox', allow_label_click: true
    assert has_unchecked_field?('retire_checkbox', visible: false)
    check 'retire_checkbox', allow_label_click: true
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
    check 'graduation_checkbox', allow_label_click: true
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
    uncheck 'graduation_checkbox', allow_label_click: true
    assert has_unchecked_field?('graduation_checkbox', visible: false)
    check 'graduation_checkbox', allow_label_click: true
    assert has_field?('user_graduated_on', with: '')
  end

  test 'edit user tag' do
    user = users(:kimura)
    visit_with_auth "/admin/users/#{user.id}/edit", 'komagata'
    tag_input = find('.ti-new-tag-input')
    tag_input.set '追加タグ'
    tag_input.native.send_keys :enter
    click_on '更新する'
    wait_for_vuejs
    visit "/admin/users/#{user.id}/edit"
    assert_text '追加タグ'
  end
end
