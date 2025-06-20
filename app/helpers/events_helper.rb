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

  def event_comment_count(event, styled: true)
    length = event.comments.length

    if styled
      link_to '#comments', class: "a-meta #{'is-disabled' if length.zero?}" do
        'コメント（'.html_safe +
          content_tag(:span, length, class: length.zero? ? 'is-muted' : 'is-emphasized') +
          '）'.html_safe
      end
    else
      "コメント（#{length}名）"
    end
  end

  def event_participant_count(event)
    "参加者（#{event.participants.count}名/#{event.capacity}名）"
  end

  def event_waitlist_count(event)
    "補欠者（#{event.waitlist.count}名）"
  end
end
