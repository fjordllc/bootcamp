class PageCallbacks
  def after_create(page)
    if !page.wip?
      send_notification(page)
    end
  end

  def after_update(page)
    if page.wip == false
      send_notification(page)
    end
  end

  private
    def send_notification(page)
      receiver_list = User.where(retired_on: nil)
      receiver_list.each do |receiver|
        if page.sender != receiver
          NotificationFacade.create_page(page, receiver)
        end
      end
    end
end
