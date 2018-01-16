json.array! @users do |user|
  json.login_name user.login_name
  json.url user.face.url(:normal)
  json.away user.updated_at <= 10.minutes.ago
  if user.away?
    json.face image_path("away.png")
  else
    json.face user.face.url(:normal)
  end
end
