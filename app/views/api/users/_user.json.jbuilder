columns = %i(id login_name long_name url roles primary_role icon_title joining_status)
json.(user, *columns)
json.avatar_url user.avatar_url
json.delayed user.completed_at >= 2.weeks.ago.end_of_day if user.respond_to?(:completed_at)
json.adviser user.adviser

if admin_or_mentor_login?
  mentor_memos = user.mentor_memos.order(Arel.sql('created_at IS NULL, created_at'))
  json.mentor_memos mentor_memos do |memo|
    json.id memo.id
    json.content memo.content
    json.author memo.author&.long_name || 'メンター'
    json.author_id memo.author_id
    json.author_avatar_url memo.author&.avatar_url || image_url(User::DEFAULT_IMAGE_PATH)
    json.created_at memo.created_at&.strftime('%Y/%m/%d') || '作成日不明'
  end
end

json.company do
  if user.company.present?
    json.logo_url user.company.logo_url
    json.url company_url(user.company)
  end
end
