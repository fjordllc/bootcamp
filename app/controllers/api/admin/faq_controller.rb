# frozen_string_literal: true

class API::Admin::FAQController < API::Admin::BaseController
  def update
    @faq = FAQ.find(params[:id])
    if @faq.insert_at(params[:insert_at].to_i)
      head :no_content
    else
      render json: @faq.errors, status: :unprocessable_entity
    end
  end
end
