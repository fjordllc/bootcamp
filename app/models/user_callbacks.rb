# frozen_string_literal: true

class UserCallbacks
  def after_update(user)
    if user.saved_change_to_retired_on?
      Product.where(user: user).unchecked.destroy_all
    end

    if user.saved_change_to_graduated_on? || user.saved_change_to_retired_on?
      user.update(job_seeking: false)
    end
  end
end
