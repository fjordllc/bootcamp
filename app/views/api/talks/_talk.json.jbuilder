json.id talk.id
json.user do
  json.partial! "api/users/user", user: talk.user
end
