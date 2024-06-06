require 'icalendar'

cal = Icalendar::Calendar.new

@events.each do |event|
  cal.event do |e|
    e.dtstart     = Icalendar::Values::DateTime.new(event.start_at)
    e.dtend       = Icalendar::Values::DateTime.new(event.end_at)
    e.summary     = event.title
    e.description = event.description
    e.location    = event.respond_to?(:location) && event.location.present? ? event.location : nil
    e.uid         = event.id.to_s
  end
end

cal.publish
response.headers['Content-Type'] = 'text/calendar'
render plain: cal.to_ical
