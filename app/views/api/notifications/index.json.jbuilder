json.array! @notifications do |notification|
  json.id notification.id
  json.kind notification.kind
  json.sender_id notification.sender_id
  json.message notification.message
  json.path notification.path
  json.avatar_url notification.sender.avatar_url
  json.read notification.read
  json.created_at time_ago_in_words(notification.created_at) + "前"
end
