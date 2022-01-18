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
    return unless page.wip == false && page.published_at.nil?

    notify_to_chat(page)
    create_author_watch(page)

    page.published_at = Time.current
    page.save
  end

  def after_save(page)
    notify_followers(page)
  end

  private

  def send_notification(page)
    receivers = User.where(retired_on: nil, graduated_on: nil, adviser: false, trainee: false)
    receivers.each do |receiver|
      p page
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

  def notify_followers(page)
    followers = page.user.followers
    send_notification(
      product: page,
      receivers: followers,
      message: "#{page.user.login_name}さんがDocsに#{page.title}を投稿しました。"
    )
    page.user.followers.each do |follower|
      create_following_watch(page, follower) if follower.watching?(page.user)
    end
  end

  def create_following_watch(page, follower)
    Watch.create!(user: follower, watchable: page)
  end
end
