json.answers @answers do |answer|
  json.partial! "api/answers/answer", answer: answer, available_emojis: @available_emojis
end

# json.totalPages @answers.total_pages
