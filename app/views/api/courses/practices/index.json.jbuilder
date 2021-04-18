json.categories @categories do |category|
  json.partial! "api/courses/practices/categories", category: category
  json.completed_all_practices current_user.completed_all_practices?(category)
end

json.learnings @learnings
