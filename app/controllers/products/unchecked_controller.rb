# frozen_string_literal: true

class Products::UncheckedController < MemberAreaController
  def index
    @products = Product.unchecked.eager_load(:user, :comments, checks: :user).order(created_at: :desc).page(params[:page])
  end
end
