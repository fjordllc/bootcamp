json.(regular_event, :id, :title, :wip, :start_at, :end_at, :finished)
json.title regular_event.title
json.start_at_localized l regular_event.start_at, format: :time_only
json.end_at_localized l regular_event.end_at, format: :time_only
json.finished regular_event.finished
json.comments_count regular_event.comments.size
json.url regular_event_url(regular_event)
json.user regular_event.user, partial: "api/users/user", as: :user
json.organizers regular_event.organizers, partial: "api/users/user", as: :user
json.holding_cycles regular_event.holding_cycles
json.category regular_event.category
