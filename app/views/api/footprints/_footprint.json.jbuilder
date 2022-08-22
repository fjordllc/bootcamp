json.user do
  json.partial! "api/users/user", user: footprint.user
end

json.user_icon footprint.user.avatar_url
json.user_id footprint.user.id
json.url footprint.user.url
json.icon_title footprint.user.icon_title
json.primary_role footprint.user.primary_role
json.title footprint.user.title