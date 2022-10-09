json.(latest_article, :title, :url, :summary, :published_at)
json.thumbnailUrl latest_article.thumbnail_url

json.user do
  json.partial! 'api/users/user', user: latest_article.user
end

