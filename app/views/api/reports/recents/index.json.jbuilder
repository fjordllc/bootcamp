json.array! @reports do |report|
  json.report report.id
  json.title truncate(report.title, length: 46)
  json.reported_on l(report.reported_on)
  json.user do
    json.partial! "api/users/user", user: report.user
  end
end
