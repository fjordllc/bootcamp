json.array! @comments do |comment|
  json.partial! "api/comments/comment", comment: comment, available_emojis: @available_emojis
end
