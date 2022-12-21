json.users @users do |user|
  json.partial! "api/generations/users/user", user: user
end
