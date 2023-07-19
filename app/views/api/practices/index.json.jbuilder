# frozen_string_literal: true

unique_practices = @categories.flat_map(&:practices).uniq

json.array! unique_practices do |practice|
  json.(practice, :id, :title)
end
