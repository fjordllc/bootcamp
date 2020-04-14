json.array! @answers do |answer|
  json.partial! "api/answers/answer", answer: answer, available_emojis: @available_emojis
end
