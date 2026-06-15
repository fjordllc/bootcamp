# frozen_string_literal: true

module EventsHelper
  def google_calendar_url(event)
    uri = URI('http://www.google.com/calendar/render')
    uri.query =
      {
        action: 'TEMPLATE',
        text: event.title,
        dates: "#{event.start_at.strftime('%Y%m%dT%H%M%S')}/#{event.end_at.strftime('%Y%m%dT%H%M%S')}",
        details: "https://bootcamp.fjord.jp/events/#{event.id}"
      }.to_param
    uri.to_s
  end

  def comment_count(commentable)
    safe_join(['コメント（', content_tag(:span, commentable.comments.size, class: 'is-emphasized'), '）'])
  end

  def event_participant_count(event)
    "参加者（#{event.participants.count}名/#{event.capacity}名）"
  end

  def event_waitlist_count(event)
    "補欠者（#{event.waitlist.count}名）"
  end
end
