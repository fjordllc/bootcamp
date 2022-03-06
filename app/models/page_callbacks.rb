# frozen_string_literal: true

class PageCallbacks
  def after_create(page)
    return if page.wip?

    send_notification(page)
    notify_to_chat(page)
    create_author_watch(page)

    page.published_at = Time.current
    page.save
  end

  def after_update(page)
    return unless page.saved_change_to_attribute?(:wip, from: true, to: false) && page.published_at.nil?

    send_notification(page)
    notify_to_chat(page)
    create_author_watch(page)

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

  def notify_to_chat(page)
    page_url = Rails.application.routes.url_helpers.polymorphic_url(
      page,
      host: 'bootcamp.fjord.jp',
      protocol: 'https'
    )

    ChatNotifier.notify(
      title: page.title,
      title_url: page_url,
      description: page.body,
      user: page.user,
      webhook_url: ENV['DISCORD_NOTICE_WEBHOOK_URL']
    )
  end

  def create_author_watch(page)
    Watch.create!(user: page.user, watchable: page)
  end
end
