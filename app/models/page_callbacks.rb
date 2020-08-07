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
  
    def notify_to_slack(page)
      link = "<#{url_for(page)}|#{page.title}>"
      SlackNotification.notify "#{link}",
        username: "#{page.user.login_name} (#{page.user.full_name})",
        icon_url: page.user.avatar_url,
        channel: "#general",
        attachments: [{
          fallback: "page body.",
          text: page.body
        }]
    end

    def send_notification(page)
      receivers = User.where(retired_on: nil, graduated_on: nil, adviser: false, trainee: false)
      receivers.each do |receiver|
        if page.sender != receiver
          NotificationFacade.create_page(page, receiver)
        end
      end
      notify_to_slack(page)
    end
end
