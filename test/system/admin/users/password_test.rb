# frozen_string_literal: true

require 'application_system_test_case'

class Admin::Users::PasswordTest < ApplicationSystemTestCase
  setup do
    login_user 'komagata', 'testtest'
    @user = users(:kimura)
  end

  test "update user's password by admin" do
    visit user_path(@user)
    click_on('管理者として情報変更')

    click_on('パスワード変更はこちらから')

    within 'form[name=password_change]' do
      fill_in 'user[password]', with: 'newpassword'
      fill_in 'user[password_confirmation]', with: 'newpassword'
      click_on '更新する'
    end
    assert_text 'パスワードを更新しました。'

    find('.test-show-menu').click
    click_link 'ログアウト'

    visit login_url
    within 'form[name=user_session]' do
      fill_in 'user[login]', with: @user.login_name
      fill_in 'user[password]', with: 'newpassword'
      click_button 'ログイン'
    end
    assert_text 'ログインしました'
  end
end
