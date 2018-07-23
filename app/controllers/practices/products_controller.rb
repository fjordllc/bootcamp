class Practices::ProductsController < ApplicationController
  def show
    @practice = Practice.find(params[:practice_id])
  end
end
