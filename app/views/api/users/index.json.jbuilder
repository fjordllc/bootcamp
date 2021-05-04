json.users @users do |user|
  json.partial! "api/users/list_user", user: user
end

json.currentUser do
  json.mentor current_user.mentor?
  json.admin current_user.admin
  json.id current_user.id
end

json.target t("target.#{@target}")
json.tag @tag
json.totalPages @users.total_pages
