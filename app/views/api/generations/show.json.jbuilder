json.users @users do |user|
    json.partial! "api/generations/user", user: user
end

json.currentUser do
    json.id current_user.id
    json.mentor current_user.mentor?
    json.admin current_user.admin
end

json.target t("target.#{@target}")
json.tag @tag
json.totalPages @users.total_pages
