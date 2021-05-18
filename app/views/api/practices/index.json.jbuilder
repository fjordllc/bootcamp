# frozen_string_literal: true
@categories.flat_map do |category|
  json.array! category.practices do |practice|
    json.(practice, :id, :title)
    json.category category.name
  end
end
