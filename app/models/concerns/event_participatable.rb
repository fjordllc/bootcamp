# frozen_string_literal: true

module EventParticipatable
  extend ActiveSupport::Concern

  def participating?(event)
    method_name = "participate_#{event.class.name.underscore.pluralize}"
    send(method_name).include?(event)
  end

  def participated_regular_event_ids
    RegularEvent.where(id: regular_event_participations.pluck(:regular_event_id), finished: false)
  end

  def involved_events
    Event.where(id: participate_events.select(:id)).or(Event.where(user_id: id))
  end

  def involved_regular_events
    RegularEvent.where(id: participate_regular_events).or(RegularEvent.where(id: organize_regular_events))
  end

  def clean_up_regular_events
    regular_event_participations.for_unfinished_events.destroy_all
    organize_regular_events.exclude_finished.each { |event| event.close_or_destroy_organizer(self) }
  end
end
