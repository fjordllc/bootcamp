json.(external_entry, :title, :url, :summary, :published_at)
json.thumbnailUrl external_entry.thumbnail_url

json.user do
  json.partial! 'api/users/user', user: external_entry.user
end

# にしたつ#TODO - このファイルは残しておく（参考：プルリク #7447）
