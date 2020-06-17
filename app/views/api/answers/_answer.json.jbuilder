json.(answer, :id, :description, :created_at, :updated_at, :type, :question_id)
json.question do
  json.created_at answer.question.created_at
end
json.user do
  json.partial! "api/users/user", user: answer.user
end
json.reaction do
  json.array! answer.reactions do |reaction|
    json.partial! "api/reactions/reaction", reaction: reaction
  end
end
json.reaction_count do
  json.array! available_emojis do |emoji|
    json.kind emoji[:kind]
    json.value emoji[:value]
    json.count answer.reaction_count_by(emoji[:kind])
    json.login_names answer.reaction_login_names_by(emoji[:kind])
  end
end
