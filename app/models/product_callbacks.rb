class ProductCallbacks
  def after_create(product)
    product.user.admin? unless send_notification(product)
  end

  private
    def send_notification(product)
      User.admin.each do |user|
        Notification.submitted(product, user)
      end
    end
end
