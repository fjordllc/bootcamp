json.(user, :id, :login_name, :name, :description, :github_account, :twitter_account, :facebook_url, :blog_url, :job_seeker, :free, :job, :os, :experience, :email, :roles, :primary_role, :icon_title, :cached_completed_percentage, :completed_fraction, :graduated_on)
json.tag_list user.tags.pluck(:name)
json.url user_url(user)
json.updated_at l(user.updated_at)
json.active user.active?
json.avatar_url user.avatar_url
json.student user.student?
json.card user.card?
json.job_name t("activerecord.enums.user.job.#{user.job}")
json.os_name t("activerecord.enums.user.os.#{user.os}")
json.experience_name t("activerecord.enums.user.experience.#{user.experience}")
json.student_or_trainee user.student_or_trainee?
json.edit_admin_user_path edit_admin_user_path(user)
json.isFollowing current_user.following?(user)
json.isWatching current_user.watching?(user)

if user.student_or_trainee?
  json.report_count user.reports.size
  json.comment_count user.comments.where.not(commentable_type: 'Talk').size
  json.product_count user.products.size
  json.question_count user.questions.size
  json.answer_count user.answers.size
  json.work_count user.works.size
end


if user.talk.present?
  json.talkUrl talk_path(user.talk)
end

json.discord_profile do
  json.account_name user.discord_profile.account_name
  json.times_url user.discord_profile.times_url
end

json.company do
  if user.company.present?
    json.id user.company.id
    json.logo_url user.company.logo_url
    json.url company_url(user.company)
  end
end

if user.hibernated?
  json.hibernated_at l(user.hibernated_at, format: :year_and_date)
  json.hibernation_elapsed_days user.hibernation_elapsed_days
end
