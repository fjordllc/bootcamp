class API::ProductTemplatesController < ApplicationController
  before_action :set_product_template, only: %i[update]

  def create
    @template = ReportTemplate.new(product_template_params)
    @practice = Practice.find(params[:practice])
    if @template.save
      render json: { id: @template.id }, status: :ok
    else
      head :bad_request
    end
  end

  def update
    if @template.update(product_template_params)
      head :ok
    else
      head :bad_request
    end
  end

  private

  def product_template_params
    params.require(:product_template).permit(:description)
  end

  def set_product_template
    @template = Practice.find(params[:practice]).product_template
  end
end
