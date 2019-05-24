json.array! @checks do |check|
  json.id check.id
  json.created_at do
    json.to_date I18n.l(check.created_at.to_date, format: :short)
  end
  json.user do
    json.(check.user, :id, :login_name)
  end
end
