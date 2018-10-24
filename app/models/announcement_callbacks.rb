# frozen_string_literal: true

class AnnouncementCallbacks
  def after_create(announce)
    send_notification(announce)
  end

  private
    def send_notification(announce)
      reciever_list = User.where(retire: false)
      reciever_list.each do |reciever|
        if announce.sender != reciever
          Notification.post_announcement(announce, reciever)
        end
      end
    end
end
