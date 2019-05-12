# frozen_string_literal: true

class API::WatchesController < API::BaseController
  include Rails.application.routes.url_helpers

  def create
    @watch = Watch.new(
      user: current_user,
      watchable: watchable
    )

    @watch.save!
    render :show, status: :created, location: api_watch_url(@watch)
  end

  def destroy
    @watch = Watch.find(params[:id])
    @watch.destroy
    head :no_content
  end

  private
    def watchable
      if params[:report_id]
        Report.find(params[:report_id])
      elsif params[:product_id]
        Product.find(params[:product_id])
      elsif params[:question_id]
        Question.find(params[:question_id])
      end
    end
end
