json.reports @reports do |report|
  json.id report.id
  json.title truncate(raw(report.title), length: 46)
  json.reportedOn l(report.reported_on)
  json.url report_url(report)
  json.editURL edit_report_path(report)
  json.newURL new_report_path(id: report)
  json.wip report.wip?
  json.check report.checks.present?
  json.hasAnyComments report.comments.any?
  if report.comments.any?
    json.numberOfComments report.comments.size
    json.lastCommentDatetime report.comments.last.updated_at.to_datetime
    json.lastCommentDate l report.comments.last.updated_at, format: :date_and_time
    json.comments do
      json.array! report.comments.uniq{ |comment| comment.user } do |comment|
        json.user_icon comment.user.avatar_url
        json.user_id comment.user.id
      end
    end
  end
  json.user do
    json.partial! "api/users/user", user: report.user
  end
end

json.current_user_id current_user.id
json.totalPages @reports.total_pages
