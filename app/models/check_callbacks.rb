# frozen_string_literal: true

class CheckCallbacks
  def after_create(check)
    if check.receiver && check.sender != check.receiver && check.checkable_type != 'Report' && check.checkable_type != 'Inquiry'
      ActivityDelivery.with(
        sender: check.sender,
        receiver: check.receiver,
        check:
      ).notify(:checked)
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

    Cache.delete_unchecked_report_count
  end

  def delete_product_cache(check)
    return unless check.checkable_type == 'Product'

    Cache.delete_unchecked_product_count
  end
end
