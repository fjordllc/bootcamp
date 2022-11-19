# frozen_string_literal: true

json.number generation.number
json.users generation.users.users_role(@target).order(:id), partial: "api/users/user", as: :user
