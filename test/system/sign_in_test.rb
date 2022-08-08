# frozen_string_literal: true

require 'application_system_test_case'

class SignInTest < ApplicationSystemTestCase
  fixtures :users

  test 'sign in with login_name' do
    visit '/login'
    within('#sign-in-form') do
      fill_in('user[login]', with: 'komagata')
      fill_in('user[password]', with: 'testtest')
    end
    click_button 'ログイン'
    assert_text 'ログインしました。'
  end

  test 'sign in with email' do
    visit '/login'
    within('#sign-in-form') do
      fill_in('user[login]', with: 'komagata@fjord.jp')
      fill_in('user[password]', with: 'testtest')
    end
    click_button 'ログイン'
    assert_text 'ログインしました。'
  end

  test 'sign in with wrong password' do
    visit '/login'
    within('#sign-in-form') do
      fill_in('user[login]', with: 'komagata')
      fill_in('user[password]', with: 'xxxxxxxx')
    end
    click_button 'ログイン'
    assert_text 'ユーザー名かパスワードが違います。'
  end

  test 'sign in with retire account' do
    visit '/login'
    within('#sign-in-form') do
      fill_in('user[login]', with: 'yameo')
      fill_in('user[password]', with: 'testtest')
    end
    click_button 'ログイン'
    assert_text '退会したユーザーです。'
  end

  test 'sign in with hibernated account' do
    visit '/login'
    within('#sign-in-form') do
      fill_in('user[login]', with: 'kyuukai')
      fill_in('user[password]', with: 'testtest')
    end
    click_button 'ログイン'
    assert_text '休会中です。休会復帰ページから手続きをお願いします。'
  end
end
