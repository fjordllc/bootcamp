# frozen_string_literal: true

class InquiryNotifier
  def call(payload)
    inquiry = payload[:inquiry]
    return if inquiry.nil?

    sender = User.find_by(login_name: 'pjord')
    User.admins.each do |receiver|
      ActivityDelivery.with(inquiry:, receiver:, sender:).notify(:came_inquiry)
    end
  end
end
