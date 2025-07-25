# frozen_string_literal: true

class InquiryNotifier
  NOTIFICATION_SENDER_NAME = 'pjord'

  def call(_name, _started, _finished, _unique_id, payload)
    inquiry = payload[:inquiry]
    return if inquiry.nil?

    sender = User.find_by(login_name: NOTIFICATION_SENDER_NAME)
    User.admins.each do |receiver|
      ActivityDelivery.with(inquiry:, receiver:, sender:).notify(:came_inquiry)
    end
  end
end
