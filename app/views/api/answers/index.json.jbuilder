json.answers @answers do |answer|
  json.partial! "api/answers/answer", answer: answer, available_emojis: @available_emojis
end

if @answers.respond_to?(:total_pages)
  json.totalPages @answers.total_pages
end
