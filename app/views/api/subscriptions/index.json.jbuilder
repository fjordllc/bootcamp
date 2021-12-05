json.subscriptions do
  json.array! @subscriptions do |subscription|
    json.id subscription['id']
    json.status subscription['status']
  end
end
