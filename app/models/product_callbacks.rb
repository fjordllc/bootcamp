# frozen_string_literal: true

class ProductCallbacks
  def after_create(product)
    send_notification(product, "#{product.user.login_name}さんが提出しました。")
  end

  def after_update(product)
    send_notification(product, "#{product.user.login_name}さんが提出物を更新しました。")
  end

  private
    def send_notification(product, message)
      User.admins.each do |user|
        Notification.submitted(product, user, message)
      end
    end
end
