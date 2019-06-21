json.array! @available_emojis do |emoji|
  json.kind emoji[:kind]
  json.value emoji[:value]
end