# frozen_string_literal: true

json.id practice.id
json.title practice.title
json.submission practice.submission

category_names = practice.category_ids.map { |category_id| Category.find(category_id).name}
json.category_names category_names

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
