class NoticeMailer < ActionMailer::Base
  default from: "noreply@bootcamp.fjord.jp"

  def contact_email(contact)
    @contact = contact
    mail subject: "[お問い合わせ]", to: "info@fjord.jp"
  end
end
