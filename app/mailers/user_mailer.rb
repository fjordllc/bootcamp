class UserMailer < ActionMailer::Base
  default from: "from@example.com"

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.reset_password_email.subject
  #
  def reset_password_email(user)
    @user = User.find user.id
    @url  = edit_password_reset_url(@user.reset_password_token)
    mail(to: user.email,
         subject: "[#{I18n.t("256interns")}] #{I18n.t("your_password_has_been_reset")}")
  end

  def contact_email(contact)
    @contact = contact
    subject = t('user_mailer.contact.subject', user: @contact.name)
    mail subject: subject, to: "hkame6926@gmail.com"
  end
end
