json.id company.id
json.name company.name
json.logo_url company.logo_url
json.description company.description
json.website company.website
json.blog_url company.blog_url

json.user do
  json.partial! "api/users/user", user: company.user
end
