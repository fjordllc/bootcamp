# frozen_string_literal: true

class API::WatchesController < API::BaseController
  include Rails.application.routes.url_helpers

  def index
    @watches = Watch.where(
      user: current_user,
      watchable: watchable
    )
  end

  def create
    @watch = Watch.new(
      user: current_user,
      watchable: watchable
    )

    @watch.save!
    render :json => @watch
  end

  def destroy
    @watch = Watch.find(params[:id])
    @watch.destroy
    head :no_content
  end

  private
    def watchable
      if params[:report_id]
        Report.find_by(id: params[:report_id])
      elsif params[:product_id]
        Product.find_by(id: params[:product_id])
      elsif params[:question_id]
        Question.find_by(id: params[:question_id])
      end
    end
end
