# frozen_string_literal: true

json.id practice.id
json.title practice.title
json.submission practice.submission

json.category_ids_names practice.category_ids do |category_id|
  json.category_id category_id
  json.category_name Category.find(category_id).name
end

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
