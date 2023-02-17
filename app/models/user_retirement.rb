# frozen_string_literal: true

class UserRetirement
  def call(user)
    if user.saved_change_to_retired_on?
      Product.where(user: user).unchecked.destroy_all
      Report.where(user: user).wip.destroy_all
      user.update(job_seeking: false)
    end

    return unless user.saved_change_to_graduated_on? && user.graduated?
  end
end
