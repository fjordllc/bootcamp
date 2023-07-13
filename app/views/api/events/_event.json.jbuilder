json.(event, :id, :title, :capacity, :wip, :start_at)
json.participants_count event.participants.count
json.waitlist_count event.waitlist.count
json.start_at_localized l(event.start_at)
json.comments_count event.comments.size
json.url event_url(event)
json.user event.user, partial: "api/users/user", as: :user
json.ended event.ended?
