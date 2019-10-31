# frozen_string_literal: true

class CheckCallbacks
  def after_create(check)
    if check.sender != check.receiver
      NotificationFacade.checked(check)
    end

    if check.checkable_type == "Product"
      check.checkable.product_checked
    end
  end
end
