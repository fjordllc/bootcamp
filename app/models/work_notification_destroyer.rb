# frozen_string_literal: true

class WorkNotificationDestroyer
  def call(payload)
    work = payload[:work]

    Notification.where(link: "/works/#{work.id}").destroy_all
  end
end
