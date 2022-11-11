# frozen_string_literal: true

class RegularEventUpdateNotifier
  def call(regular_event)
    participants = regular_event.participants
    participants.each do |target|
      NotificationFacade.update_regular_event(regular_event, target) if regular_event.user != target
    end
  end
end