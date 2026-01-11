# frozen_string_literal: true

class OrganizerCreateNotifier
  def call(_name, _started, _finished, _id, payload)
    regular_event = payload[:regular_event]
    sender = payload[:sender]
    before_organizer_ids = payload[:before_organizer_ids]
    after_organizer_ids = RegularEvent.find(regular_event.id).organizer_ids
    new_organizer_ids = after_organizer_ids - before_organizer_ids
    return if new_organizer_ids.blank?

    new_organizer_users = Organizer.where(id: new_organizer_ids).includes(:user)

    new_organizer_users.each do |new_organizer_user|
      ActivityDelivery.with(regular_event:, sender:, receiver: new_organizer_user.user).notify(:create_organizer)
    end
  end
end
