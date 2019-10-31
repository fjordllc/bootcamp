# frozen_string_literal: true

class ProductCallbacks
  def after_create(product)
    unless product.wip?
      create_watch(
        watchers: User.admins,
        watchable: product
      )

      if product.user.trainee?
        send_notification(
          product: product,
          receivers: product.user.company.advisers,
          message: "#{product.user.login_name}さんが#{product.title}を提出しました。"
        )
        create_watch(
          watchers: product.user.company.advisers,
          watchable: product,
        )
      end
      change_learning_status_to_submitted(product)
    end
  end

  def after_destroy(product)
    delete_notification(product)
  end

  private
    def send_notification(product:, receivers:, message:)
      receivers.each do |receiver|
        NotificationFacade.submitted(product, receiver, message)
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

    def change_learning_status_to_submitted(product)
      learning = Learning.find_by(user_id: product.user.id, practice_id: product.practice.id)
      if learning
        learning.product_submitted
      else
        Learning.create(user_id: product.user.id, practice_id: product.practice.id, status: "submitted")
      end
    end
end
