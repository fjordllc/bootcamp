json.categories @categories do |category|
  json.partial! "api/courses/practices/categories", category: category
end

json.learnings @learnings
