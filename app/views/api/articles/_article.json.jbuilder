json.id article.id
json.title article.title
json.body article.body
json.summary article.summary
json.target article.target
json.wip article.wip?
json.published_at article.published_at
json.created_at article.created_at
json.updated_at article.updated_at
json.tags article.tag_list
json.thumbnail_type article.thumbnail_type
json.thumbnail_attached article.thumbnail.attached?
json.thumbnail_url article.prepared_thumbnail? ? article.prepared_thumbnail_url : article.selected_thumbnail_url
json.display_thumbnail_in_body article.display_thumbnail_in_body?
json.token article.token if article.wip? && admin_or_mentor_login?

json.user do
  json.id article.user.id
  json.login_name article.user.login_name
  json.name article.user.name
end
