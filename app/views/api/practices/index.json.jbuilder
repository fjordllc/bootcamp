# frozen_string_literal: true

json.array! @unique_practices do |practice|
  json.(practice, :id, :title)
end
