# frozen_string_literal: true

module InquiryDecorator
  def sender_name_and_email
    "#{name} 様 （#{email}）"
  end
end
