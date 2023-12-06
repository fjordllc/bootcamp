# frozen_string_literal: true

json.id company.id
json.name company.name
json.description company.description
json.logo_url company.logo_url
json.users_url company_users_url(company)

allowed_targets = %w[all trainee adviser graduate mentor]
users = company.users.users_role(@target, allowed_targets: allowed_targets).order(:id)
json.users users, partial: "api/users/user", as: :user
