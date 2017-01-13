# Preview all emails at http://localhost:3000/rails/mailers/notice_mailer
class NoticeMailerPreview < ActionMailer::Preview

  # Preview this email at http://localhost:3000/rails/mailers/notice_mailer/contact_email
  def contact_email
    contact = Contact.first
    NoticeMailer.contact_email(contact)
  end

end
