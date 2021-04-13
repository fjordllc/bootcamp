# frozen_string_literal: true

json.array! @practices do |practice|
  json.(practice, :id, :title)
  json.category practice.category(@course).name
end
