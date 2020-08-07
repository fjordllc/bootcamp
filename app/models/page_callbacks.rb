class PageCallbacks
  def after_create(page)
    send_notification(page)
  end

  private
    def send_notification(page)
      reciever_list = User.all
      reciever_list.each do |reciever|
        if page.sender != reciever
          Notification.create_page(page, reciever)
        end
      end
    end
end
