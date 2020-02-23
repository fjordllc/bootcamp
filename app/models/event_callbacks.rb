# frozen_string_literal: true

class EventCallbacks
  def after_update(event)
    if event.saved_change_to_attribute?("capacity")
      ordered_participations(event).each.with_index(1) do |participation, i|
        if i <= event.capacity
          participation.update(enable: true)
          send_notification(event, participation.user) if waited?(participation)
        else
          participation.update(enable: false)
        end
      end
    end
  end

  private
    def ordered_participations(event)
      event.participations.order(created_at: :asc)
    end

    def waited?(participation)
      participation.saved_change_to_attribute?("enable", from: false, to: true)
    end

    def send_notification(event, receiver)
      NotificationFacade.moved_up_event_waiting_user(event, receiver)
    end
end
