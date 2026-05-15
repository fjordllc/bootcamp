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
    create_advisers_watch product if !product.wip && product.user.trainee? && product.user.company

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
      ActivityDelivery.with(product:, receiver:).notify(:submitted)
    end
  end

  def delete_notification(product)
    Notification.where(link: "/products/#{product.id}").destroy_all
  end
end
