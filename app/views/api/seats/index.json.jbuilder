json.array! @seats do |seat|
  json.(seat, :id, :name)
end
