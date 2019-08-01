# frozen_string_literal: true

class ProductCallbacks
  def after_create(product)
    send_trainee_submit_notification(product, "#{product.user.login_name}さんが提出しました。")
    send_notification(product, "#{product.user.login_name}さんが提出しました。")
    create_admin_watch(product)
  end

  def after_update(product)
    send_notification(product, "#{product.user.login_name}さんが提出物を更新しました。")
  end

  def after_destroy(product)
    delete_notification(product)
  end

  private
    def send_notification(product, message)
      User.admins.each do |user|
        Notification.submitted(product, user, message)
      end
    end

    def send_trainee_submit_notification(product, message)
      recievers = User.where(company: product.user.company).where(adviser: true)
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

    def delete_notification(product)
      Notification.where(path: "/products/#{product.id}").destroy_all
    end
end
