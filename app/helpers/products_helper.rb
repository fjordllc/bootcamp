# frozen_string_literal: true

module ProductsHelper
  def product_link(name)
    current_user.admin? && Product.unchecked.exists? ? "is-active" : current_link(name)
  end
end
