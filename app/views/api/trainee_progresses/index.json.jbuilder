json.trainees @trainees do |trainee|
  user_course_practice = UserCoursePractice.new(trainee)

  json.id trainee.id
  json.loginName trainee.login_name
  json.longName trainee.long_name
  json.avatarUrl trainee.avatar_url

  json.company do
    if trainee.company.present?
      json.id trainee.company.id
      json.name trainee.company.name
    end
  end

  json.course do
    json.id trainee.course.id
    json.title trainee.course.title
  end

  json.progress do
    json.completedPracticesCount user_course_practice.completed_required_practices.size
    json.requiredPracticesCount user_course_practice.required_practices.size
    json.completedPercentage user_course_practice.completed_percentage.round(1)
  end

  json.activePractices trainee.active_practices do |practice|
    json.id practice.id
    json.title practice.title
  end

  json.lastActivityAt trainee.last_activity_at
  json.createdAt trainee.created_at
end
