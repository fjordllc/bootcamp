if current_user.id.in?(@question.watches.pluck(:user_id))
  json.id @question.id
  json.watch_id @question.watches.ids[0]
end
