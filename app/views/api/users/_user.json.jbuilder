columns = %i(id login_name long_name url role icon_title)
columns << :mentor_memo if admin_or_mentor_login?
json.(user, *columns)
json.avatar_url user.avatar_url
json.daimyo user.daimyo?
