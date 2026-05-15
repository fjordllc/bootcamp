json.array! @tags do |tag|
  json.id tag.id
  json.value tag.to_s
end
