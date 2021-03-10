json.reports @reports do |report|
  json.partial! "api/reports/report", report: report
  json.partial! "api/reports/checks", checks: report.checks
  json.partial! "api/comments/user_icons", comments: report.comments
  json.user do
    json.partial! "api/users/user", user: report.user
  end
end

json.currentUserId current_user.id
json.totalPages @reports.total_pages
