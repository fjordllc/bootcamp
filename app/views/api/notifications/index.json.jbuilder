json.notifications do
  json.array! @notifications do |notification|
    json.id notification.id
    json.kind notification.kind
    json.message notification.message
    json.path notification.path
    json.read notification.read
    json.created_at notification.created_at
    json.sender do
      json.partial! 'api/users/user', user: notification.sender
    end
  end
end
json.total_pages @notifications.page(1).total_pages
