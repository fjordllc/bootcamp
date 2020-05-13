json.(reservation, :id, :seat_id, :user_id, :date)
json.login_name reservation.user.login_name
json.admin reservation.user.admin
