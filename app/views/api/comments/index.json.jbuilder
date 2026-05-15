json.comments @comments do |comment|
  json.partial! "api/comments/comment", comment: comment, available_emojis: @available_emojis
end
json.comment_total_count @comment_total_count
