# frozen_string_literal: true

class API::EventsController < API::BaseController
  def index
    pagination = API::Pagination.new(params)
    schedule = API::EventSchedule.new(params)
    return render_bad_request unless pagination.valid? && schedule.valid?

    events = schedule.occurrences
    render json: {
      events: events.slice(pagination.offset, pagination.per_page).to_a.map { |event| event_json(event) },
      total_pages: (events.size.to_f / pagination.per_page).ceil
    }
  end

  private

  def event_json(occurrence)
    event = occurrence.original_event
    end_at = event.is_a?(Event) ? event.end_at : event.transform_for_subscription(occurrence.scheduled_date).end_on
    {
      kind: event.model_name.singular, id: event.id, title: event.title, url: polymorphic_path(event),
      start_at: occurrence.scheduled_date_with_start_time.iso8601, end_at: end_at.iso8601,
      held: occurrence.held_on_scheduled_date?
    }
  end
end
