# frozen_string_literal: true

class PageNotifier
  def call(_name, _started, _finished, _unique_id, payload)
    page = payload[:page]
    send_notification(page)
    notify_to_chat(page)

    page.published_at = Time.current
    page.save
  end

  private

  def send_notification(page)
    receivers = User.admins_and_mentors
    receivers.each do |receiver|
      ActivityDelivery.with(receiver:, page:).notify(:create_page) if page.sender != receiver
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
      <#{page_url}>
    TEXT
  end
end
