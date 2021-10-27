# frozen_string_literal: true

class ProductCallbacks
  def after_create(product)
    create_author_watch(product)

    Cache.delete_unchecked_product_count
    Cache.delete_not_responded_product_count
    Cache.delete_unassigned_product_count
    Cache.delete_self_assigned_no_replied_product_count(product.checker_id)
  end

  def after_save(product)
    if !product.wip? && product.published_at.nil?
      notify_to_watching_mentor(product)
      if product.user.trainee?
        send_notification(
          product: product,
          receivers: product.user.company.advisers,
          message: "#{product.user.login_name}さんが#{product.title}を提出しました。"
        )
        create_watch(
          watchers: product.user.company.advisers,
          watchable: product
        )
      end
      product.published_at = Time.current
      product.save
      product.change_learning_status(:submitted)
    end

    Cache.delete_unchecked_product_count
  end

  def after_destroy(product)
    delete_notification(product)

    Cache.delete_unchecked_product_count
    Cache.delete_not_responded_product_count
    Cache.delete_unassigned_product_count
    Cache.delete_self_assigned_no_replied_product_count(product.checker_id)
  end

  private

  def create_author_watch(product)
    Watch.create!(user: product.user, watchable: product)
  end

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

  def notify_to_watching_mentor(product)
    practice = Practice.find(product.practice_id)
    mentor_ids = practice.watches.where.not(user_id: product.user_id).pluck(:user_id)
    mentors = User.where(id: mentor_ids)
    send_notification(
      product: product,
      receivers: mentors,
      message: "#{product.user.login_name}さんが#{product.title}を提出しました。"
    )
  end
end
