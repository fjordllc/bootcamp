# frozen_string_literal: true

class RegularEventUpdateNotifier
  def call(regular_event)
    participants = regular_event.participants

    participants.each do |participant|
      ActivityDelivery.with(regular_event: regular_event, receiver: participant).notify(:update_regular_event) if regular_event.user != participant
    end
  end
end
