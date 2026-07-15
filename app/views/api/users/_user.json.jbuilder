columns = %i(id login_name long_name url roles primary_role icon_title joining_status)
json.(user, *columns)
json.avatar_url user.avatar_url
json.delayed user.completed_at >= 2.weeks.ago.end_of_day if user.respond_to?(:completed_at)
json.adviser user.adviser

if admin_or_mentor_login?
  json.mentor_memos user.mentor_memos do |memo|
    json.content memo.content
    json.author memo.author&.long_name
    json.created_at memo.created_at
  end
end

json.company do
  if user.company.present?
    json.logo_url user.company.logo_url
    json.url company_url(user.company)
  end
end
