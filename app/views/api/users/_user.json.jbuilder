# TODO: メンターのみメモを取得できるようにする
json.(user, :id, :login_name, :url, :role, :icon_title, :memo)
json.avatar_url user.avatar_url
json.daimyo user.daimyo?
