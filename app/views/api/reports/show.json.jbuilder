if current_user.id.in?(@report.watches.pluck(:user_id))
  json.id @report.id
  json.watch_id @report.watches.ids[0]
end
