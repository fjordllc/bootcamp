json.id question.id
json.title truncate(question.title, {length: 46, escape: false})
json.url question_url(question)
json.has_correct_answer question.correct_answer.present?

json.updated_at do
  json.datetime question.updated_at.to_datetime
  json.locale l(question.updated_at)
end

json.user do
  json.partial! 'api/users/user', user: question.user
end

json.practice do
  json.title question.practice.title
end if question.practice

json.answers do
  json.size question.answers.size
end

json.tags question.tags.each do |tag|
  json.name tag.name
  json.url questions_url(tag: tag.name, all: true)
end

