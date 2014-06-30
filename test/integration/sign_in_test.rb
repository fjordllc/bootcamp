require 'test_helper'

class SignInTest < ActionDispatch::IntegrationTest
  fixtures :users

  test 'success' do
    visit '/login'
    within('form.user') do
      fill_in('user[login_name]', with: 'komagata')
      fill_in('user[password]',   with: 'testtest')
    end
    click_button 'サインイン'
    assert_equal current_path, '/users'
  end

  test 'fail' do
    visit '/login'
    within('form.user') do
      fill_in('user[login_name]', with: 'komagata')
      fill_in('user[password]',   with: 'xxxxxxxx')
    end
    click_button 'サインイン'
    assert_equal current_path, '/user_sessions'
    assert page.has_content?('ユーザー名かパスワードが違います。')
  end
end
