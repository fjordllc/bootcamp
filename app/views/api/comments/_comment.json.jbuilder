json.(comment, :id, :description, :created_at, :updated_at, :commentable_type, :commentable_id)
json.commentable do
  json.created_at comment.commentable.created_at
end
json.user do
  json.partial! "api/users/user", user: comment.user
end
json.reaction do
  json.array! comment.reactions do |reaction|
    json.partial! "api/reactions/reaction", reaction: reaction
  end
end
json.reaction_count do
  json.array! available_emojis do |emoji|
    json.kind emoji[:kind]
    json.value emoji[:value]
    json.count comment.reaction_count_by(emoji[:kind])
    json.login_names comment.reaction_login_names_by(emoji[:kind])
  end
end
