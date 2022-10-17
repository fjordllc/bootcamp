# frozen_string_literal: true

json.id practice.id
json.title practice.title
json.submission practice.submission
json.category_ids practice.category_ids

json.products do
  json.size practice.products.size
end

json.reports do
  json.size practice.reports.size
end

json.questions do
  json.size practice.questions.size
end

json.categories_practice do
  json.size practice.categories_practices.size
end
