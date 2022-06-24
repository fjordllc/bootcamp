json.(regular_event, :id, :title, :wip, :wday, :start_at, :end_at, :finished)
json.title regular_event.title
json.wday regular_event.wday
json.start_at_localized l regular_event.start_at, format: :time_only
json.end_at_localized l regular_event.end_at, format: :time_only
json.finished regular_event.finished
json.comments_count regular_event.comments.size
json.url regular_event_url(regular_event)
json.user regular_event.user, partial: "api/users/user", as: :user
json.organizers regular_event.organizers do |organizer|
  json.id organizer.id
  json.avatar_url organizer.avatar_url
  json.icon_title organizer.icon_title
  json.primary_role organizer.primary_role
  json.login_name organizer.login_name
  json.long_name organizer.long_name
  json.url organizer.url
end
