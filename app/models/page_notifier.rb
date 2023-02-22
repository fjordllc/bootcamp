# frozen_string_literal: true

class PageNotifier
  def call(page)
    send_notification(page)
    notify_to_chat(page)
    create_author_watch(page)

    page.published_at = Time.current
    page.save
  end

  private

  def send_notification(page)
    receivers = User.where(admin: true).or(User.where(mentor: true))
    receivers.each do |receiver|
      ActivityDelivery.with(receiver: receiver, page: page).notify(:create_page) if page.sender != receiver
    end
  end

  def notify_to_chat(page)
    page_url = Rails.application.routes.url_helpers.polymorphic_url(
      page,
      host: 'bootcamp.fjord.jp',
      protocol: 'https'
    )

    ChatNotifier.message(<<~TEXT)
      Docs：「#{page.title}」が作成されました。
      #{page_url}
    TEXT
  end

  def create_author_watch(page)
    Watch.create!(user: page.user, watchable: page)
  end
end
