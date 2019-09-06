# frozen_string_literal: true

module BookDecorator
  def borrowing_user_name
    users.first.login_name
  end

  def borrowing_user_avatar
    users.first.avatar_image
  end

  def borrowing_days
    borrowed_date = borrowings.first.created_at
    (Time.current - borrowed_date).to_i / (60 * 60 * 24)
  end
end
