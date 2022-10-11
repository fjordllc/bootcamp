json.id practice.id
json.title practice.title
json.submission practice.submission

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
