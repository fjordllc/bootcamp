# frozen_string_literal: true

class UserCallbacks
  def before_create(user)
    user.unsubscribe_email_token = SecureRandom.urlsafe_base64
  end

  def before_save(user)
    return unless user.will_save_change_to_times_url?

    match = user.times_url&.match(%r{\A(https://discord\.com/channels/\d+/\d+)(?:/\d+)?\z})
    user.times_url = match.captures.first if match
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
