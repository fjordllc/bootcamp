@users.each do |user|
  json.set! user.login_name, user.avatar.attached? ? rails_storage_proxy_url(user.avatar.variant(resize_to_limit: [56, 56])) : ''
end
