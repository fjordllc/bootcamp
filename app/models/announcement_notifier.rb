# frozen_string_literal: true

class AnnouncementNotifier
  def call(announce)
    target_users = User.announcement_receiver(announce.target)
    target_users.each do |target|
      NotificationFacade.post_announcement(announce, target) if announce.sender != target
    end
  end
end
