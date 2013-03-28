require 'spec_helper'

feature 'Sign in' do
  background do
    FactoryGirl.create(:user, :programmer, login_name: 'hrysd', password: 'hogehoge')
  end

  scenario 'successfully' do
    visit login_path
    within('form.user') do
      fill_in('user[login_name]', with: 'hrysd')
      fill_in('user[password]',   with: 'hogehoge')
    end
    click_button 'サインイン'
    current_path.should == '/users'
  end

  scenario 'falid' do
    visit login_path
    within('form.user') do
      fill_in('user[login_name]', with: 'hrysd')
      fill_in('user[password]',   with: 'pipipipi')
    end
    click_button 'サインイン'
    current_path.should == '/user_sessions'
    page.should have_content 'ユーザー名かパスワードが違います。'
  end
end
