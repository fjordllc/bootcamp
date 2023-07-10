# frozen_string_literal: true

user_practices = @categories.flat_map do |category|
  category.practices
end

unique_practices = user_practices.uniq

json.array! unique_practices do |practice|
  json.(practice, :id, :title)
end
