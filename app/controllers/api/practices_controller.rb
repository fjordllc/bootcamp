# frozen_string_literal: true

class API::PracticesController < API::BaseController
  before_action :set_practice, only: %i(show update)
  before_action :require_mentor_login, only: %i(show update)

  def show
  end

  def update
    if @practice.update(practice_params)
      head :ok
    else
      head :bad_request
    end
  end

  private

    def set_practice
      @practice = Practice.find(params[:id])
    end

    def practice_params
      params.require(:practice).permit(:memo)
    end
end
