# frozen_string_literal: true

class WorkNotificationDestroyer
  def call(_name, _started, _finished, _unique_id, payload)
    work = payload[:work]

    Notification.where(link: "/works/#{work.id}").destroy_all
  end
end
