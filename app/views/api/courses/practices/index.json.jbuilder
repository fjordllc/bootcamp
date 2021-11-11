json.categories @categories do |category|
  json.partial! "api/courses/practices/categories", category: category
  json.completed_all_practices category.practices.size == @completed_practices_size_by_category[category.id]
  json.edit_admin_category_path edit_admin_category_path(category, course_id: @course.id)
end

json.learnings @learnings
