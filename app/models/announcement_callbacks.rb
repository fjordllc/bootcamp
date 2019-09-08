# frozen_string_literal: true

class AnnouncementCallbacks
  def after_create(announce)
    send_notification(announce)
  end

  private
    def send_notification(announce)
      receiver_list = User.where(retired_on: nil)
      receiver_list.each do |receiver|
        if announce.sender != receiver
          NotificationFacade.post_announcement(announce, receiver)
        end
      end
    end
end
