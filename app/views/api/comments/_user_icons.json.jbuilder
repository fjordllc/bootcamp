json.hasAnyComments report.comments.present?
if report.comments.present?
  json.numberOfComments report.comments.size
  json.lastCommentDatetime report.comments.last.updated_at.to_datetime
  json.lastCommentDate l report.comments.last.updated_at, format: :date_and_time
  json.comments do
    json.array! report.commented_users.uniq do |user|
      json.user_icon user.avatar_url
      json.user_id user.id
      json.primary_role user.primary_role
      json.joining_status user.joining_status
    end
  end
end
