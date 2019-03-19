# frozen_string_literal: true

class UserCallbacks
  def after_update(user)
    if user.saved_change_to_retired_on?
      Product.where(user: user).unchecked.destroy_all
    end
  end
end
