# frozen_string_literal: true

json.call(@question, :id, :title, :description, :tag_list, :correct_answer, :created_at, :updated_at, :wip)

json.user do
  json.partial! 'api/users/user', user: @question.user
end

if @question.practice
  json.practice do
    json.call(@question.practice, :id, :title, :description, :created_at, :updated_at)
  end
end

json.reaction do
  json.array! @question.reactions do |reaction|
    json.partial! 'api/reactions/reaction', reaction: reaction
  end
end
json.reaction_count do
  json.array! @available_emojis do |emoji|
    json.kind emoji[:kind]
    json.value emoji[:value]
    json.count @question.reaction_count_by(emoji[:kind])
    json.login_names @question.reaction_login_names_by(emoji[:kind])
  end
end
