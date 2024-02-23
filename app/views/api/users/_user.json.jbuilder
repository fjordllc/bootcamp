columns = %i(id login_name long_name url roles primary_role icon_title)
columns << :mentor_memo if admin_or_mentor_login?
json.(user, *columns)
json.avatar_url user.avatar_url
json.delayed user.completed_at >= 2.weeks.ago.end_of_day if user.respond_to?(:completed_at)
json.adviser user.adviser

json.company do
  if user.company.present?
    json.logo_url user.company.logo_url
    json.url company_url(user.company)
  end
end
