json.hasCheck checks.present?
if checks.present?
  json.checkDate l checks.last.created_at.to_date, format: :short
  json.checkUserName checks.last.user.login_name
end
