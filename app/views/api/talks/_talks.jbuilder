json.talks do
  json.array! talks do |talk|
    json.partial! 'api/talks/talk', talk: talk
    json.has_any_comments talk.comments.present?
    if talk.comments.present?
      json.number_of_comments talk.comments.size
      json.last_comment_user talk.comments.last.user
      json.last_comment_user_icon talk.comments.last.user.avatar_url
      json.last_commented_at l talk.comments.last.updated_at
    end
  end
end
