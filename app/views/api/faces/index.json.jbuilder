json.array! @users do |user|
  json.login_name user.login_name
  json.url user.face.url(:normal)
  json.away user.updated_at <= 10.minutes.ago
  json.link user_url(user)
  if user.away? || !user.face?
    json.face gravatar_url(user, secure: true)
  else
    json.face user.face.url(:normal)
  end
end
