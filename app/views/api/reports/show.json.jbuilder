json.partial! "api/reports/report", report: @report
json.partial! "api/reports/checks", checks: @report.checks

json.user do
  json.partial! "api/users/user", user: @report.user
end

json.practices @report.practices do |practice|
  json.id practice.id
  json.title practice.title
end

json.comments @report.comments.order(:created_at) do |comment|
  json.id comment.id
  json.description comment.description
  json.createdAt comment.created_at
  json.user do
    json.partial! "api/users/user", user: comment.user
  end
end
