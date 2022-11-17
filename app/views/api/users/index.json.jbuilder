json.users @users do |user|
  json.partial! "api/users/list_user", user: user
end

json.currentUser do
  json.id current_user.id
  json.mentor current_user.mentor?
  json.adviser current_user.adviser
  json.company_id current_user.company_id
  json.admin current_user.admin
end

json.target t("target.#{@target}")
json.tag @tag
json.totalPages @users.total_pages if @users.respond_to? :total_pages
