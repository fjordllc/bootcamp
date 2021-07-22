@users.each do |user|
  json.set! user.login_name, user.avatar.attached? ? rails_storage_proxy_url(user.avatar) : ''
end
