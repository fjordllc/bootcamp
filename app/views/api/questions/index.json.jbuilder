json.questions @questions do |question|
  json.partial! 'api/questions/question', question: question
end

json.totalPages @questions.total_pages
