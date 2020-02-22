# frozen_string_literal: true

class ParticipationCallbacks
  def after_create(participation)
    participation.enable = participation.event.can_participate?
    participation.save
  end

  def after_destroy(participation)
    waiting_participation = participation.event
                                         .participations
                                         .disabled
                                         .order(created_at: :asc)
                                         .first

    if waiting_participation && participation.enable
      waiting_participation.update(enable: true)
      send_notification(waiting_participation.event, waiting_participation.user)
    end
  end

  private
    def send_notification(event, receiver)
      NotificationFacade.moved_up_event_waiting_user(event, receiver)
    end
end
