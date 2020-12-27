if mentor_login? || admin_login?
  json.(user, :id, :login_name, :url, :role, :icon_title, :memo)
else
  json.(user, :id, :login_name, :url, :role, :icon_title)
end
json.avatar_url user.avatar_url
json.daimyo user.daimyo?
