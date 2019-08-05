# frozen_string_literal: true

class ProductCallbacks
  def after_create(product)
    send_notification(
      product: product,
      recievers: User.admins,
      message: "#{product.user.login_name}さんが提出しました。"
    )
    send_notification(
      product: product,
      recievers: product.user.company.advisers,
      message: "#{product.user.login_name}さんが提出しました。"
    )
    create_admin_watch(product)
    create_adviser_watch(product) if product.user.trainee?
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
        Notification.submitted(product, reciever, message)
      end
    end

    def create_admin_watch(product)
      User.admins.each do |admin|
        @watch = Watch.new(
          user: admin,
          watchable: product
        )
        @watch.save!
      end
    end

    def create_adviser_watch(product)
      User.advisers.where(company: product.user.company).each do |adviser|
        Watch.create(user: adviser, watchable: product)
      end
    end

    def delete_notification(product)
      Notification.where(path: "/products/#{product.id}").destroy_all
    end
end
