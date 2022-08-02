# frozen_string_literal: true

class ProductCallbacks
  def after_create(product)
    create_author_watch(product)

    Cache.delete_unchecked_product_count
    Cache.delete_unassigned_product_count
    Cache.delete_self_assigned_no_replied_product_count(product.checker_id)
  end

  def after_update(product)
    return unless product.saved_change_to_attribute?('checker_id')

    checker_id = product.checker_id || product.attribute_before_last_save('checker_id')
    Cache.delete_self_assigned_no_replied_product_count(checker_id)
    Cache.delete_unassigned_product_count
  end

  def after_save(product)
    update_learning_status(product)

    unless product.wip
      notify_watching_mentors(product)
      notify_watching_advisers(product)
    end

    Cache.delete_unchecked_product_count
  end

  def after_destroy(product)
    delete_notification(product)

    Cache.delete_unchecked_product_count
    Cache.delete_unassigned_product_count if product.unassigned?
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

  def delete_notification(product)
    Notification.where(link: "/products/#{product.id}").destroy_all
  end

  def notify_watching_mentors(product)
    practice = Practice.find(product.practice_id)
    mentor_ids = practice.watches.where.not(user_id: product.user_id).pluck(:user_id)
    mentors = User.where(id: mentor_ids)
    send_notification(
      product: product,
      receivers: mentors,
      message: "#{product.user.login_name}さんが#{product.title}を提出しました。"
    )
  end

  def notify_watching_advisers(product)
    return unless product.user.trainee? && product.user.company

    send_notification(
      product: product,
      receivers: product.user.company.advisers,
      message: "#{product.user.login_name}さんが#{product.title}を提出しました。"
    )
  end

  def update_learning_status(product)
    status = if product.wip
               started_practice = product.user.learnings.map(&:status).include?('started')
               started_practice ? :unstarted : :started
             else
               :submitted
             end
    product.change_learning_status status
  end
end
