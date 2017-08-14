require 'test_helper'

class FootprintTest < ActionDispatch::IntegrationTest

  test 'create footprint' do
    visit '/login'
    within('#sign-in-form') do
      fill_in('user[login_name]', with: 'tanaka')
      fill_in('user[password]', with: 'testtest')
    end
    click_button 'サインイン'
    assert_equal current_path, '/users'
    click_link '日報'
    assert_text '作業週2日目'
    click_link '作業週2日目'
    assert_text '見たよ'
    assert page.has_css?('.footprints-item__checker-icon.is-tanaka')
  end

end
