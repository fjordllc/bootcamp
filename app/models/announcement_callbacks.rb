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
      target_users = target_users(announce.target)
      target_users.each do |target|
        if announce.sender != target
          NotificationFacade.post_announcement(announce, target)
        end
      end
    end

    def delete_notification(announce)
      Notification.where(path: "/announcements/#{announce.id}").destroy_all
    end

    def target_users(target)
      case target
      when "all"
        User.where(retired_on: nil)
      when "active_users"
        User.where(admin: true)
        .or(
          User.where(retired_on: nil, graduated_on: nil, adviser: false, mentor: false, trainee: false)
        )
      when "job_seeker"
        User.admins
        .or(
          User.where(retired_on: nil, adviser: false, mentor: false, trainee: false, job_seeker: true)
        )
      else
        User.none
      end
    end
end
