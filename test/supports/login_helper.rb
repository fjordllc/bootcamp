# frozen_string_literal: true

module LoginHelper
  def login_user(login_name, password)
    visit "/login"
    within("#sign-in-form") do
      fill_in("user[login_name]", with: login_name)
      fill_in("user[password]", with: password)
    end
    click_button "ログイン"
  end

  def logout
    visit "/logout"
  end
end
