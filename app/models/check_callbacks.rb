# frozen_string_literal: true

class CheckCallbacks
  def after_create(check)
    if check.sender != check.receiver && check.checkable_type != 'Report'
      ActivityDelivery.with(
        sender: check.sender,
        receiver: check.receiver,
        check:
      ).notify(:checked)

      notify_advisers check if check.checkable.user.trainee? && check.checkable.user.company
    end

    delete_report_cache(check)
    delete_product_cache(check)
  end

  def after_destroy(check)
    delete_report_cache(check)
    delete_product_cache(check)
  end

  private

  def delete_report_cache(check)
    return unless check.checkable_type == 'Report'

    report = check.checkable
    Cache.delete_unchecked_report_count
    Cache.delete_user_unchecked_report_count(report.user_id)
  end

  def delete_product_cache(check)
    return unless check.checkable_type == 'Product'

    Cache.delete_unchecked_product_count
  end

  def notify_advisers(check)
    send_notification(
      check:,
      receivers: check.checkable.user.company.advisers
    )
  end

  def send_notification(check:, receivers:)
    receivers.each do |receiver|
      ActivityDelivery.with(check:, receiver:).notify(:checked)
    end
  end
end
