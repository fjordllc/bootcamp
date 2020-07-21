# frozen_string_literal: true

json.array! @practices do |practice|
  json.(practice, :id, :title, :category_id)
end
