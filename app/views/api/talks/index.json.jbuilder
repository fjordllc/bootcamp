json.talks do
  json.array! @users_talks do |talk|
    json.partial! "api/talks/talk", talk: talk
    json.hasAnyComments talk.comments.present?
    if talk.comments.present?
      json.numberOfComments talk.comments.size
      json.lastCommentUser talk.comments.last.user
      json.lastCommentUserIcon talk.comments.last.user.avatar_url
      json.lastCommentTime l talk.comments.last.updated_at
    end
  end
end

json.target t("target.#{@target}")
json.totalPages @users_talks.total_pages
