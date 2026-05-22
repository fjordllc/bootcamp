# frozen_string_literal: true

module LoginHelper
  def login_user(login_name, password)
    visit '/login'
    within('#sign-in-form') do
      fill_in('user[login]', with: login_name)
      fill_in('user[password]', with: password)
    end
    click_button 'ログイン'
  end

  def logout
    visit '/logout'
  rescue Playwright::TargetClosedError, Playwright::TimeoutError
    nil
  rescue Playwright::Error => e
    raise unless e.message.include?('net::ERR_ABORTED')
  end
end
