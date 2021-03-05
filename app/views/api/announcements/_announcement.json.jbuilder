json.id announcement.id
json.user announcement.user.login_name
json.title announcement.title
json.description announcement.description
json.target announcement.target
json.wip announcement.wip
json.created_at l(announcement.created_at)
json.created_at_date_time announcement.created_at.to_datetime

if announcement.published_at.present?
  json.published_at l(announcement.published_at)
  json.published_at_date_time announcement.published_at.to_datetime
end

if announcement.updated_at.present?
  json.updated_at l(announcement.updated_at)
  json.updated_at_date_time announcement.updated_at.to_datetime
end
