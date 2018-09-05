require "application_system_test_case"

class ResetPasswordTest < ApplicationSystemTestCase
  def setup
    ActionMailer::Base.deliveries.clear
  end

  test "send email to exist user" do
    visit "/login"
    first(".auth-form-item__help-link").click
    within("#password_resets_form") do
      fill_in("email", with: users(:komagata).email)
    end

    assert_difference "ActionMailer::Base.deliveries.count" do
      click_button "パスワードをリセットする"
    end

    mail = ActionMailer::Base.deliveries.last
    assert "[Fjord Bootcamp] #{I18n.t("your_password_has_been_reset")}"
    assert users(:komagata).email, mail.to
    assert "from@bootcamp.fjord.jp", mail.from
    assert_match /#{I18n.t("greeting", recipient: "#{users(:komagata).last_name} #{users(:komagata).first_name}")}/, mail.body.to_s
    assert_match /#{I18n.t("someone_wanted_to_reset_the_password")}/, mail.body.to_s
    assert_match /#{I18n.t("if_you_did_not_wish_please_disregard_this_email")}/, mail.body.to_s
    password_resets_url = "#{ActionMailer::Base.default_url_options[:host]}:#{ActionMailer::Base.default_url_options[:port]}#{edit_password_reset_path(User.find_by(email: users(:komagata).email).reset_password_token)}"
    assert_match /#{password_resets_url}/, mail.body.to_s
    assert_match /#{I18n.t("the_password_will_not_be_changed_until_you_access_the_link_above_and_set_a_new_password")}/, mail.body.to_s

    assert_equal "/login", current_path
    assert_text I18n.t("instruction_have_been_sent")
  end

  test "Returns an error for mail addresses that do not exist" do
    visit "/login"
    first(".auth-form-item__help-link").click
    within("#password_resets_form") do
      fill_in("email", with: "not_exist_user@email.address")
    end

    assert_no_difference "ActionMailer::Base.deliveries.count" do
      click_button "パスワードをリセットする"
    end

    assert_equal "/login", current_path
    assert_text I18n.t("invalid_email_or_password")
  end
end
