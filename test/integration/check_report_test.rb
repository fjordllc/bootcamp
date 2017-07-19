require 'test_helper'

class CheckReportTest < ActionDispatch::IntegrationTest

  test 'Success Repost Checking' do
    visit '/login'
    within('#sign-in-form') do
      fill_in('user[login_name]', with: 'machida')
      fill_in('user[password]', with: 'testtest')
    end
    click_button 'サインイン'
    assert_equal current_path, '/users'
    click_link '日報'
    assert_text '作業週2日目'
    click_link '作業週2日目'
    assert has_button? 'このレポートをチェックする'
    click_button 'このレポートをチェックする'
    assert_not has_button? 'このレポートをチェックする'
    assert_text 'レポートをチェックしました。'
  end

  test 'non button in current_user report' do
    visit '/login'
    within('#sign-in-form') do
      fill_in('user[login_name]', with: 'komagata')
      fill_in('user[password]', with: 'testtest')
    end
    click_button 'サインイン'
    assert_equal current_path, '/users'
    click_link '日報'
    assert_text '作業週2日目'
    click_link '作業週2日目'
    assert_not has_button? 'このレポートをチェックする'
  end
end
