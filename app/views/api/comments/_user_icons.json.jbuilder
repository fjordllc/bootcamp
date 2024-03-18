json.hasAnyComments comments.present?
if comments.present?
  json.numberOfComments comments.size
  json.lastCommentDatetime comments.last.updated_at.to_datetime
  json.lastCommentDate l comments.last.updated_at, format: :date_and_time
  json.comments do
    json.array! comments do |comment|
      json.user_icon comment.user.avatar_url
      json.user_id comment.user.id
      json.primary_role comment.user.primary_role
    end
  end
end
