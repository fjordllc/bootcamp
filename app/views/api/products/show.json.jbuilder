if current_user.id.in?(@product.watches.pluck(:user_id))
  json.id @product.id
  json.watch_id @product.watches.ids[0]
end
