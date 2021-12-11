# frozen_string_literal: true

class UserCallbacks
  def before_create(user)
    user.unsubscribe_email_token = SecureRandom.urlsafe_base64
  end

  def after_create(user)
    user.build_talk
    user.save
  end

  def after_update(user)
    if user.saved_change_to_retired_on?
      Product.where(user: user).unchecked.destroy_all
      Report.where(user: user).wip.destroy_all
    end

    user.update(job_seeking: false) if user.saved_change_to_retired_on?

    return unless user.saved_change_to_graduated_on? && user.graduated?
  end
end
