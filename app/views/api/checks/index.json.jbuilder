json.array! @checks do |check|
  json.id check.id
  json.created_at I18n.l(check.created_at.to_date, format: :short)
  json.user do
    json.(check.user, :id, :login_name)
  end
end
