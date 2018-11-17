json.array! @categories do |category|
  json.partial! "api/categories/category", category: category
end
