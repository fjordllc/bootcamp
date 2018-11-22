# frozen_string_literal: true

class Reports::UncheckedController < ApplicationController
  def index
    @reports = Report.unchecked.eager_load(:user, :comments, checks: :user).default_order.page(params[:page])
  end
end
