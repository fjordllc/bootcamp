json.categories @categories do |category|
  json.id category.id
  json.name category.name
  json.slug category.slug
  json.description category.description

  json.practices do
    json.array! category.practices do |practice|
      json.practice practice
      json.include_must_read_books practice.include_must_read_books?
      json.url practice_path(practice)
      json.learning_minute_statistic practice.learning_minute_statistic
      json.started_or_submitted_students practice.started_or_submitted_students.each do |user|
        json.active user.active?
        json.updated_at user.updated_at
        json.user_link user_path(user)
        json.avatar_url user.avatar_url
        json.icon_title user.icon_title
        json.roles user.roles
        json.primary_role user.primary_role
        json.joining_status user.joining_status
      end
    end
  end

  json.completed_all_practices category.practices.size == @completed_practices_size_by_category[category.id]
  json.edit_mentor_category_path edit_mentor_category_path(category, course_id: @course_id)
end

json.learnings @learnings
