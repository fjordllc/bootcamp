json.id announcement.id
json.user do
  json.partial! "api/users/user", user: announcement.user
end
json.title announcement.title
json.description announcement.description
json.target announcement.target
json.wip announcement.wip
json.url announcement_path(id: announcement)
json.new_url new_announcement_path(id: announcement)
json.created_at l(announcement.created_at)
json.created_at_date_time announcement.created_at.to_datetime
json.updated_at l(announcement.updated_at)
json.updated_at_date_time announcement.updated_at.to_datetime

if announcement.published_at?
  json.published_at l(announcement.published_at)
  json.published_at_date_time announcement.published_at.to_datetime
end

json.commentsSize announcement.comments.size
