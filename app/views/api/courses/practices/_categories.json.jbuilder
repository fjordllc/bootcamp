json.id category.id
json.name category.name
json.slug category.slug
json.position category.position
json.description category.description
json.practices do
  json.array! category.practices do |practice|
    json.practice practice
    json.url practice_path(practice)
    json.learning_minute_statistic practice.learning_minute_statistic
    json.partial! "api/practices/started_students", practice: practice
  end
end
