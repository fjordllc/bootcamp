# frozen_string_literal: true

class API::EventSchedule
  attr_reader :from, :to

  def initialize(params)
    @from = parse_date(params.fetch(:from, Date.current.iso8601))
    @to = parse_date(params.fetch(:to, @from ? (@from + 6.days).iso8601 : ''))
  end

  def valid?
    from.present? && to.present? && (0..30).cover?((to - from).to_i)
  end

  def occurrences
    special = Event.where(wip: false).where('start_at < ? AND end_at > ?', (to + 1.day).in_time_zone, from.in_time_zone).not_ended
                   .map { |event| UpcomingEvent.new(event, event.start_at.to_date) }
    regular = RegularEvent.not_finished.preload(:regular_event_repeat_rules, :regular_event_skip_dates).flat_map do |event|
      event.all_scheduled_dates(from:, to:).filter_map do |date|
        UpcomingEvent.new(event, date) unless event.ended?(date)
      end
    end
    (special + regular).sort_by { |event| [event.scheduled_date_with_start_time, event.event_type.name, event.original_event.id] }
  end

  private

  def parse_date(value)
    return unless value.is_a?(String) && value.match?(/\A[0-9]{4}-[0-9]{2}-[0-9]{2}\z/)

    date = Date.iso8601(value)
    date if date.year.positive?
  rescue Date::Error
    nil
  end
end
