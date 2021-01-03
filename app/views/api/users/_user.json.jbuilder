columns = %i(id login_name url role icon_title)
columns << :memo if mentor_login? || admin_login?
json.(user, *columns)
json.avatar_url user.avatar_url
json.daimyo user.daimyo?
