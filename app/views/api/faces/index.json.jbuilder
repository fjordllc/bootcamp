# frozen_string_literal: true

json.array! @users do |user|
  json.login_name user.login_name
  json.away user.updated_at <= 10.minutes.ago
  json.link user_url(user)

  if user.face.attached? && !user.away?
    json.url url_for(user.face)
    json.face url_for(user.face)
  else
    json.url url_for(user.avatar)
    json.face url_for(user.avatar)
  end
end
