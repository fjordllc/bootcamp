# frozen_string_literal: true

class ProductCallbacks
  def after_create(product)
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

  def after_commit(product)
    unless product.wip
      notify_watching_mentors product
      create_advisers_watch product if product.user.trainee? && product.user.company
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

  def create_advisers_watch(product)
    product.user.company.advisers.each do |adviser|
      target = { user: adviser, watchable: product }
      Watch.create! target unless Watch.exists? target
    end
  end

  def send_notification(product:, receivers:)
    receivers.each do |receiver|
      ActivityDelivery.with(product: product, receiver: receiver).notify(:submitted)
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
      receivers: mentors
    )
  end
end
