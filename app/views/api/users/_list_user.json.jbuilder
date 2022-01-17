json.(user, :id, :login_name, :name, :discord_account, :description, :github_account, :twitter_account, :facebook_url, :blog_url, :times_url, :job_seeker, :free, :job, :os, :experience, :email, :role, :icon_title, :cached_completed_percentage, :completed_fraction, :graduated_on)
json.tag_list user.tags.pluck(:name)
json.url user_url(user)
json.updated_at l(user.updated_at)
json.active user.active?
json.avatar_url user.avatar_url
json.daimyo user.daimyo?
json.student user.student?
json.card user.card?
json.job_name t("activerecord.enums.user.job.#{user.job}")
json.os_name t("activerecord.enums.user.os.#{user.os}")
json.experience_name t("activerecord.enums.user.experience.#{user.experience}")
json.student_or_trainee user.student_or_trainee?
json.edit_admin_user_path edit_admin_user_path(user)
json.isFollowing current_user.following?(user)
json.isWatching current_user.watching?(user)

json.company do
  if user.company.present?
    json.id user.company.id
    json.logo_url user.company.logo_url
    json.url company_url(user.company)
  end
end
