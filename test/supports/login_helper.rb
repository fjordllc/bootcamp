# frozen_string_literal: true

module LoginHelper
  def login_user(login_name, password)
    visit '/login'
    assert_selector 'h1.auth-form__title', text: 'ログイン'
    within('#sign-in-form') do
      fill_in('user[login]', with: login_name)
      fill_in('user[password]', with: password)
    end
    click_button 'ログイン'
    assert(
      has_selector?('h2.page-header__title', text: 'ダッシュボード', wait: 3) ||
        has_selector?('h1.auth-form__title', text: 'ログイン', wait: 3)
    )
  end

  def logout
    visit '/logout'
  end
end
