# frozen_string_literal: true

json.id company.id
json.name company.name
json.description company.description
json.logo_url company.logo_url
json.users_url company_users_url(company)

allowed_targets = %w[all trainee adviser graduate mentor]
json.users company.users.users_role(@target, allowed_targets: allowed_targets, default_target: 'all').order(:id), partial: "api/users/user", as: :user
