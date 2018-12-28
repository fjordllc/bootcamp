# frozen_string_literal: true

json.array! @users do |user|
  json.login_name user.login_name
  json.away user.updated_at <= 10.minutes.ago
  json.link user_url(user)

  if user.away? || !user.face.attached?
    json.url gravatar_url(user, secure: true)
    json.face gravatar_url(user, secure: true)
  else
    json.url rails_blob_url(user.face)
    json.face rails_blob_url(user.face)
  end
end
