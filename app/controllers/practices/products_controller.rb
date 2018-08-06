class Practices::ProductsController < ApplicationController
  def index
    @practice = Practice.find(params[:practice_id])
  end
end
