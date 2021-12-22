json.(page, :id, :title, :wip, :practice)
json.url page_url(page)
json.user do
  json.partial! "api/users/user", user: page.user
end

if page.published_at.present?
  json.published_at l(page.published_at)
  json.published_at_date_time page.published_at.to_datetime
end

if page.updated_at.present?
  json.updated_at l(page.updated_at)
  json.updated_at_date_time page.updated_at.to_datetime
end

json.commentsSize page.comments.size

json.tags page.tags.each do |tag|
  json.name tag.name
  json.url pages_url(tag: tag.name, all: true)
end
