# frozen_string_literal: true

class PageCallbacks
  def after_create(page)
    return if page.wip?

    send_notification(page)
    notify_to_slack(page)
    page.published_at = Time.current
    page.save
  end

  def after_update(page)
    return unless page.wip == false && page.published_at.nil?

    send_notification(page)
    notify_to_slack(page)
    page.published_at = Time.current
    page.save
  end

  private

  def send_notification(page)
    receivers = User.where(retired_on: nil, graduated_on: nil, adviser: false, trainee: false)
    receivers.each do |receiver|
      NotificationFacade.create_page(page, receiver) if page.sender != receiver
    end
  end

  def notify_to_slack(page)
    path = Rails.application.routes.url_helpers.polymorphic_path(page)
    url = "https://bootcamp.fjord.jp#{path}"
    link = "<#{url}|#{page.title}>"
    SlackNotification.notify link.to_s,
                             username: "#{page.user.login_name} (#{page.user.name})",
                             icon_url: page.user.avatar_url,
                             channel: '#bootcamp_notification',
                             attachments: [{
                               fallback: 'page body.',
                               text: page.body
                             }]
  end
end
