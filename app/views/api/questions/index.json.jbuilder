# frozen_string_literal: true

json.array! @questions do |question|
  json.partial! 'api/questions/question', question: question, available_emojis: @available_emojis
end
