# frozen_string_literal: true

class Practices::ProductsController < ApplicationController
  def index
    @practice = Practice.find(params[:practice_id])
    @products = Product
      .includes(
        :practice,
        :comments,
        :checks,
        user: [:company, { avatar_attachment: :blob }])
      .where(practice: @practice)
      .order(created_at: :desc)
      .page(params[:page])
  end
end
