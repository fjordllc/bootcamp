json.id product.id
json.checker_id product.checker_id
json.checker_name product.checker_name
json.checker_avatar product.checker_avatar
json.wip product.wip
json.url product_url(product)
json.created_at l(product.created_at)
json.created_at_date_time product.created_at.to_datetime

if product.published_at.present?
  json.published_at l(product.published_at)
  json.published_at_date_time product.published_at.to_datetime
end

if product.updated_at.present?
  json.updated_at l(product.updated_at)
  json.updated_at_date_time product.updated_at.to_datetime
end

if product.self_last_commented_at.present?
  json.self_last_commented_at l(product.self_last_commented_at)
  json.self_last_commented_at_date_time product.self_last_commented_at.to_datetime
end

if product.mentor_last_commented_at.present?
  json.mentor_last_commented_at l(product.mentor_last_commented_at)
  json.mentor_last_commented_at_date_time product.mentor_last_commented_at.to_datetime
end

json.user do
  json.partial! "api/users/user", user: product.user
  if product.user.training_ends_on
    json.training_ends_on l(product.user.training_ends_on)
    json.training_remaining_days product.user.training_remaining_days
  end
end

json.practice do
  json.title product.practice.title
end

json.comments do
  json.size product.comments.size
  if product.comments.size > 0
    json.last_created_at l(product.comments.last.created_at)
    json.last_created_at_date_time product.comments.last.created_at.to_datetime
    commented_users = product.comments.includes(:user).map(&:user).uniq
    json.users commented_users do |user|
      json.avatar_url user.avatar_url
      json.url user_path(user)
      json.icon_title user.icon_title
      json.primary_role user.primary_role
      json.joining_status user.joining_status
    end
  end
end

json.checks do
  json.size product.checks.size
  if product.checks.size > 0
    json.last_created_at l(product.checks.last.created_at.to_date, format: :short)
    json.last_user_login_name product.checks.last.user.login_name
  end
end
