json.id category.id
json.name category.name
json.slug category.slug
json.position category.position
json.description category.description
json.practices do
  json.array! category.practices do |practice|
    json.practice practice
    json.url practice_url(practice)
    json.learning_minute_statistic practice.learning_minute_statistic
    json.started_students practice.started_students.each do |user|
      json.acticve user.active?
      json.updated_at user.updated_at
      json.user_link user_url(user)
      json.avatar_url user.avatar_url
      json.icon_title user.icon_title
      json.role user.role
    end
  end
end