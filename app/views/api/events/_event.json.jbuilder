json.(event, :id, :title, :capacity, :wip, :start_at, :participants_count, :waitlist_count)
json.start_at_localized l(event.start_at)
json.comments_count event.comments.size
json.url event_url(event)
json.user event.user, partial: "api/users/user", as: :user
json.is_closing event.closing?
