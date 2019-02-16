# frozen_string_literal: true

json.array! @users do |user|
  json.login_name user.login_name
  json.away user.updated_at <= 10.minutes.ago
  json.link user_url(user)

  if user.face.attached? && !user.away?
    json.url url_for(user.face_image(72))
    json.face url_for(user.face_image(72))
  else
    json.url url_for(user.avatar_image(72))
    json.face url_for(user.avatar_image(72))
  end
end
