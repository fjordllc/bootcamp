# frozen_string_literal: true

class OrganizerNotifier
  def call(_name, _started, _finished, _id, payload)
    regular_event = payload[:regular_event]
    sender = payload[:sender]
    new_organizer_users = payload[:new_organizer_users]

    new_organizer_users.each do |user|
      ActivityDelivery.with(regular_event:, sender:, receiver: user).notify(:added_organizer)
    end
  end
end
