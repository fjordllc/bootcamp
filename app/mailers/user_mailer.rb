class UserMailer < ActionMailer::Base
  default from: "from@example.com"

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.reset_password_email.subject
  #
  def reset_password_email
    @greeting = "Hi"

    mail to: "to@example.org"
  end

  def contact_email(contact)
    @contact = contact
    subject = t('user_mailer.contact.subject', user: @contact.name)
    mail subject: subject, to: "info@fjord.jp"
  end
end
