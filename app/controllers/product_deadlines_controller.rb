# frozen_string_literal: true

class ProductDeadlinesController < ApplicationController
  def update
    product_deadline = Product::PRODUCT_DEADLINE
    product_deadline.update(product_deadline_params)
  end

  private

  def product_deadline_params
    params.require(:product_deadline).permit(:alert_day)
  end
end
