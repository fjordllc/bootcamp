# frozen_string_literal: true

class Products::UnassignedController < ApplicationController
  before_action :require_staff_login
  def index
    @product_deadline_day = ProductDeadline.first_or_create(alert_day: 4).alert_day
  end
end
