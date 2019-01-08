# frozen_string_literal: true

class UserMailer < ApplicationMailer
  default from: "info@fjord.jp"

  def reset_password_email(user)
    @user = User.find user.id
    @url  = edit_password_reset_url(@user.reset_password_token)
    mail to: user.email,
         subject: "パスワードのリセット"
  end

  def welcome(user)
    @user = user
    mail to: user.email, subject: "フィヨルドブートキャンプへようこそ"
  end
end
