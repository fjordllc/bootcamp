module LoginHelper
  def login_user(login_name, passwrod)
    visit "/login"
    within("#sign-in-form") do
      fill_in("user[login_name]", with: login_name)
      fill_in("user[password]", with: passwrod)
    end
    click_button "サインイン"
  end
end
