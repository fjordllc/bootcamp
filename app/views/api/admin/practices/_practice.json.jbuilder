json.id practice.id
json.title practice.title
json.description practice.description

# json.categories do
#   json.name practice.category_name.name
# end

json.products do
  json.size practice.products.size
end

json.reports do
  json.size practice.reports.size
end

json.questions do
  json.size practice.questions.size
end
