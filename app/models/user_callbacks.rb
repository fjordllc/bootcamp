# frozen_string_literal: true

class UserCallbacks
  def before_create(user)
    user.unsubscribe_email_token = SecureRandom.urlsafe_base64
  end

  def after_update(user)
    if user.saved_change_to_retired_on?
      Product.where(user: user).unchecked.destroy_all
      Report.where(user: user).wip.destroy_all
    end

    user.update(job_seeking: false) if user.saved_change_to_retired_on?

    return unless user.saved_change_to_graduated_on? && user.graduated?

    notify_to_slack(user)
  end

  private

  def notify_to_slack(user)
    path = Rails.application.routes.url_helpers.user_path(user)
    url = "https://bootcamp.fjord.jp#{path}"
    SlackNotification.notify "<#{url}|#{user.login_name}>さんが卒業しました！おめでとうございます🎉",
                             username: "#{user.login_name} (#{user.name})",
                             icon_url: user.avatar_url,
                             channel: "#fjord"
  end
end
