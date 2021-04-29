json.started_students practice.started_students.each do |user|
  json.acticve user.active?
  json.updated_at user.updated_at
  json.user_link user_path(user)
  json.avatar_url user.avatar_url
  json.icon_title user.icon_title
  json.role user.role
end
