# frozen_string_literal: true

class ProductDeadlinesController < ApplicationController
  def update
    product_deadline = ProductDeadline.first_or_initialize
    product_deadline.update(alert_day: params[:alert_day])
  end
end
