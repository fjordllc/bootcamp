json.array! @reports do |report|
  json.id report.id
  json.title truncate(raw(report.title), length: 46)
  json.reported_on l(report.reported_on)
  json.url report_url(report)
  json.check report.checks.present?
  json.user do
    json.partial! "api/users/user", user: report.user
  end
end
