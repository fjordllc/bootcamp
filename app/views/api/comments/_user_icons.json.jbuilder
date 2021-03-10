json.hasAnyComments comments.present?
if comments.present?
  json.numberOfComments comments.size
  json.lastCommentDatetime comments.last.updated_at.to_datetime
  json.lastCommentDate l comments.last.updated_at, format: :date_and_time
  json.comments do
    json.array! comments.commented_users do |user|
      json.user_icon user.avatar_url
      json.user_id user.id
    end
  end
end
