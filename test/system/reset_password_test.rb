# frozen_string_literal: true

require "application_system_test_case"

class ResetPasswordTest < ApplicationSystemTestCase
  def setup
    ActionMailer::Base.deliveries.clear
  end

  test "send email to exist user" do
    visit "/login"
    first(".a-form-help-link").click
    within("#password_resets_form") do
      fill_in("email", with: users(:komagata).email)
    end

    assert_difference "ActionMailer::Base.deliveries.count" do
      click_button "パスワード再設定"
    end

    mail = ActionMailer::Base.deliveries.last
    assert "[Fjord Bootcamp] #{I18n.t("your_password_has_been_reset")}"
    assert users(:komagata).email, mail.to
    assert "from@bootcamp.fjord.jp", mail.from
    assert_match /こんにちは、#{users(:komagata).last_name} #{users(:komagata).first_name}さん/, mail.body.to_s
    assert_match /誰かがパスワードの再設定を希望しました/, mail.body.to_s
    assert_match /あなたが希望したのではないのなら、このメールは無視してください/, mail.body.to_s
    password_resets_url = "#{ActionMailer::Base.default_url_options[:host]}:#{ActionMailer::Base.default_url_options[:port]}#{edit_password_reset_path(User.find_by(email: users(:komagata).email).reset_password_token)}"
    assert_match /#{password_resets_url}/, mail.body.to_s
    assert_match /上のリンクにアクセスして新しいパスワードを設定するまで、パスワードは変更されません/, mail.body.to_s

    assert_equal "/login", current_path
    assert_text "パスワードの再設定について"
  end

  test "user who does not have kana column can reset password" do
    visit "/login"
    first(".a-form-help-link").click
    within("#password_resets_form") do
      fill_in("email", with: users(:kananashi).email)
    end

    assert_difference "ActionMailer::Base.deliveries.count" do
      click_button "パスワード再設定"
    end

    reset_password_token = edit_password_reset_path(User.find_by(email: users(:kananashi).email).reset_password_token)
    visit reset_password_token
    fill_in("user[password]", with: "ABC123!!")
    fill_in("user[password_confirmation]", with: "ABC123!!")
    click_button "更新する"
    assert_text "パスワードが変更されました。"
  end

  test "Returns an error for mail addresses that do not exist" do
    visit "/login"
    first(".a-form-help-link").click
    within("#password_resets_form") do
      fill_in("email", with: "not_exist_user@email.address")
    end

    assert_no_difference "ActionMailer::Base.deliveries.count" do
      click_button "パスワード再設定"
    end

    assert_equal "/login", current_path
    assert_text "ユーザー名かパスワードが違います。"
  end
end
