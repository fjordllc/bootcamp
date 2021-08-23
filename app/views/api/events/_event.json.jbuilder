json.(event, :id, :title, :capacity, :wip, :participants_count, :waitlist_count)
json.comments_count event.comments.size
json.start_at l(event.start_at)
json.start_at_datetime event.start_at.to_datetime
json.url event_url(event)

json.user do
  json.partial! "api/users/user", user: event.user
  json.long_name event.user.long_name
end
