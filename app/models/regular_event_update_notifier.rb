# frozen_string_literal: true

class RegularEventUpdateNotifier
  def call(payload)
    regular_event = payload[:regular_event]
    sender = payload[:sender]
    participants = regular_event.participants

    participants.each do |participant|
      ActivityDelivery.with(regular_event:, sender:, receiver: participant).notify(:update_regular_event) if regular_event.user != participant
    end
  end
end
