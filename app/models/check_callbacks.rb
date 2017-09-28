class CheckCallbacks
  def after_create(check)
    if check.sender != check.reciever
      Notification.checked(check)
    end
  end
end
