# frozen_string_literal: true

class CheckCallbacks
  def after_create(check)
    if check.sender != check.receiver
      NotificationFacade.checked(check)
    end

    update_product_status(check)
  end

  private

    def update_product_status(check)
      if check.checkable_type == "Product"
        check.checkable.change_learning_status(:complete)
      end
    end
end
