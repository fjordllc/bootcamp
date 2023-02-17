# frozen_string_literal: true

class UserRetirement
  def call(user)
    if user.saved_change_to_retired_on?
      Product.where(user: user).unchecked.destroy_all
      Report.where(user: user).wip.destroy_all
      user.update(job_seeking: false)
    end
  end
end
