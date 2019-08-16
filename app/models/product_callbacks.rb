# frozen_string_literal: true

class ProductCallbacks
  def after_create(product)
    send_notification(
      product: product,
      recievers: User.admins,
      message: "#{product.user.login_name}さんが提出しました。"
    )
    create_watch(
      watchers: User.admins,
      watchable: product
    )

    if product.user.trainee?
      send_notification(
        product: product,
        recievers: product.user.company.advisers,
        message: "#{product.user.login_name}さんが提出しました。"
      )
      create_watch(
        watchers: product.user.company.advisers,
        watchable: product,
      )
    end
  end

  def after_update(product)
    send_notification(
      product: product,
      recievers: User.admins,
      message: "#{product.user.login_name}さんが提出物を更新しました。"
    )
  end

  def after_destroy(product)
    delete_notification(product)
  end

  private
    def send_notification(product:, recievers:, message:)
      recievers.each do |reciever|
        NotificationFacade.submitted(product, reciever, message)
      end
    end

    def create_watch(watchers:, watchable:)
      watchers.each do |watcher|
        Watch.create!(user: watcher, watchable: watchable)
      end
    end

    def delete_notification(product)
      Notification.where(path: "/products/#{product.id}").destroy_all
    end
end
