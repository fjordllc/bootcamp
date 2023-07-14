json.practices do
  json.array! @practices do |practice|
    json.partial! "api/mentor/practices/practice", practice: practice
  end
end
