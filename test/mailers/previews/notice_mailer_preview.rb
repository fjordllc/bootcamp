# frozen_string_literal: true

class NoticeMailerPreview < ActionMailer::Preview
  def contact_email
    contact = Contact.first
    NoticeMailer.contact_email(contact)
  end
end
