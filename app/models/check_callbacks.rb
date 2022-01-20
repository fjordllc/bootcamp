# frozen_string_literal: true

class CheckCallbacks
  def after_create(check)
    NotificationFacade.checked(check) if check.sender != check.receiver && check.checkable_type != 'Report'

    update_product_status(check)
    delete_report_cache(check)
    delete_product_cache(check)
  end

  def after_destroy(check)
    delete_report_cache(check)
    delete_product_cache(check)
  end

  private

  def update_product_status(check)
    return unless check.checkable_type == 'Product'

    check.checkable.change_learning_status(:complete)
  end

  def delete_report_cache(check)
    return unless check.checkable_type == 'Report'

    Cache.delete_unchecked_report_count
  end

  def delete_product_cache(check)
    return unless check.checkable_type == 'Product'

    Cache.delete_unchecked_product_count
  end
end
