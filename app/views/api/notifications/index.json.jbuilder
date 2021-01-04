json.notifications do
  json.array! @notifications do |notification|
    json.id notification.id
    json.kind notification.kind
    json.message notification.message
    json.path notification.path
    json.read notification.read
    json.created_at l(notification.created_at)
    json.created_at_time_ago time_ago_in_words(notification.created_at) + '前'
    json.sender do
      json.partial! 'api/users/user', user: notification.sender
    end
  end
end
json.total_pages @notifications.page(1).total_pages
