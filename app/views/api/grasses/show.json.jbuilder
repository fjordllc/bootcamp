json.array! @times do |time|
  json.date time.date
  json.velocity time.velocity
end
