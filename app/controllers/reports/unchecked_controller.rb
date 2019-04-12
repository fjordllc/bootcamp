# frozen_string_literal: true

class Reports::UncheckedController < MemberAreaController
  def index
    @reports = Report.unchecked.eager_load(:user, :comments, checks: :user).default_order.page(params[:page])
  end
end
