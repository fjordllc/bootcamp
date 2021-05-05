json.(user, :id, :login_name, :name, :discord_account, :description, :job_seeker, :free, :job, :os, :experience, :email)
json.url user_url(user)
json.updatedAt l(user.updated_at)
json.studentOrTrainee user.student_or_trainee?
json.active user.active?
json.avatar_url user.avatar_url
json.daimyo user.daimyo?
json.student_or_trainee user.student_or_trainee?
json.edit_admin_user_path edit_admin_user_path(user)
json.isFollowing current_user.following?(user)

json.company do
  if user.company.present?
    json.id user.company.id
    json.logo_url user.company.logo_url
    json.url company_url(user.company)
  end
end
