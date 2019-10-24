# frozen_string_literal: true

class AnnouncementCallbacks
  def after_create(announce)
    send_notification(announce)
  end

  def after_destroy(announce)
    delete_notification(announce)
  end

  private
    def send_notification(announce)
      receiver_list = receiver_list(announce.receive_user_code)
      receiver_list.each do |receiver|
        if announce.sender != receiver
          NotificationFacade.post_announcement(announce, receiver)
        end
      end
    end

    def delete_notification(announce)
      Notification.where(path: "/announcements/#{announce.id}").destroy_all
    end

    def receiver_list(receive_user_code)
      case receive_user_code
      when "all"
        User.where(retired_on: nil)
      when "active_users"
        User.where(admin: true)
        .or(
          User.where(retired_on: nil, graduated_on: nil, adviser: false, mentor: false, trainee: false)
        )
      else
        nil
      end
    end
end
