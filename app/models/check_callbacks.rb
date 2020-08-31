# frozen_string_literal: true

class CheckCallbacks
  def after_create(check)
    if check.sender != check.receiver
      NotificationFacade.checked(check)
    end

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
      if check.checkable_type == "Product"
        check.checkable.change_learning_status(:complete)
      end
    end

    def delete_report_cache(check)
      if check.checkable_type == "Report"
        Cache.delete_unchecked_report_count
      end
    end

    def delete_product_cache(check)
      if check.checkable_type == "Product"
        Cache.delete_not_responded_product_count
      end
    end
end
