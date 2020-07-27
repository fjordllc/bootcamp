# frozen_string_literal: true

class EventCallbacks
  def after_create(event)
    create_watch(
      watchers: User.admins,
      watchable: event
    )
  end

  def after_destroy(event)
    delete_notification(event)
  end

  private
    # def send_notification(event:, receivers:, message:)
    #   receivers.each do |receiver|
    #     NotificationFacade.submitted(event, receiver, message)
    #   end
    # end

    def create_watch(watchers:, watchable:)
      watchers.each do |receiver|
        Watch.create!(user: watcher, watchable: watchable)
      end
    end

    def delete_notification(product)
      Notification.where(path: "/events/#{event.id}").destroy_all
    end
end
