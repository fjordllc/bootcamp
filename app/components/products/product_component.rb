# frozen_string_literal: true

class Products::ProductComponent < ViewComponent::Base
  def initialize(product:)
    @product = product
  end
end
