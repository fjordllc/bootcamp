# frozen_string_literal: true

class UserEventInvolvement
  def initialize(user)
    @user = user
  end

  def participating?(event)
    method_name = "participate_#{event.class.name.underscore.pluralize}"
    @user.send(method_name).include?(event)
  end

  def participated_regular_event_ids
    RegularEvent.where(id: @user.regular_event_participations.pluck(:regular_event_id), finished: false)
  end

  def involved_events
    Event.where(id: @user.participate_events.select(:id)).or(Event.where(user_id: @user.id))
  end

  def involved_regular_events
    RegularEvent.where(id: @user.participate_regular_events).or(RegularEvent.where(id: @user.organize_regular_events))
  end

  def clean_up_regular_events
    @user.regular_event_participations.for_unfinished_events.destroy_all
    @user.organize_regular_events.exclude_finished.each { |event| event.close_or_destroy_organizer(@user) }
  end
end
