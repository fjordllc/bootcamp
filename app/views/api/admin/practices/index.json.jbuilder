json.practices do
  json.array! @practices do |practice|
    json.partial! "api/admin/practices/practice", practice: practice
  end
end
