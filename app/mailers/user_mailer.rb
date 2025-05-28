# frozen_string_literal: true

class UserMailer < ApplicationMailer
  def reset_password_email(user)
    @user = User.find(user.id)
    @url = edit_password_reset_url(@user.reset_password_token)
    mail to: user.email, subject: '[FBC] パスワードのリセット'
  end

  def welcome(user)
    @user = user
    mail to: user.email, bcc: 'info@lokka.jp', subject: '[FBC] フィヨルドブートキャンプへようこそ'
  end

  def retire(user)
    @user = user
    mail to: user.email, bcc: 'info@lokka.jp', subject: '[FBC] 退会処理が完了しました'
  end

  def auto_retire(user)
    @user = user
    mail to: user.email, bcc: 'info@lokka.jp', subject: '[FBC] 重要なお知らせ：受講ステータスの変更について'
  end

  def request_retirement(request_retirement)
    email = request_retirement.user.email
    @request_retirement = request_retirement
    mail to: email, bcc: 'info@lokka.jp', subject: '[FBC] 退会申請を受け付けました'
  end

  def one_week_before_auto_retire(user)
    @user = user
    mail to: user.email, bcc: 'info@lokka.jp', subject: '[FBC] ご注意：休会期限の接近について'
  end
end
