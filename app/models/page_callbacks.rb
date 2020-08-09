# frozen_string_literal: true

class PageCallbacks
  def after_create(page)
    if !page.wip?
      send_notification(page)
      page.published_at = Time.current
      page.save
    end
  end

  def after_update(page)
    if page.wip == false && page.published_at.nil?
      send_notification(page)
      page.published_at = Time.current
      page.save
    end
  end

  private
    def send_notification(page)
      receivers = User.where(retired_on: nil, graduated_on: nil, adviser: false, trainee: false)
      receivers.each do |receiver|
        if page.sender != receiver
          NotificationFacade.create_page(page, receiver)
        end
      end
    end
end
