json.array! @watches do |watch|
  json.(watch, :id, :watchable_id, :watchable_type, :user_id)
end
