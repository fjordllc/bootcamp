json.subscriptions do
  json.array! @subscriptions do |subscription|
    json.id subscription['id']
    json.status subscription['cancel_at_period_end'] ? 'canceled' : subscription['status']
  end
end
