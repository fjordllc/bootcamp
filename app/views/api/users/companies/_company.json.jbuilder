# frozen_string_literal: true

json.id company.id
json.name company.name
json.description company.description
json.logo_url company.logo_url
json.users_url company_users_url(company)

json.users company.users.order(:id), partial: "api/users/user", as: :user
