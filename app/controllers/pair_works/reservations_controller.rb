# frozen_string_literal: true

class PairWorks::ReservationsController < ApplicationController
  before_action :require_mentor_login, only: %i[create]

  def create
    @pair_work = PairWork.find(params[:pair_work_id])
    if @pair_work.reserve(pair_work_reservation_params)
      ActiveSupport::Notifications.instrument('pair_work.reserve', pair_work: @pair_work)
      redirect_to Redirection.determin_url(self, @pair_work), notice: @pair_work.generate_notice_message(:reserve)
    else
      @comments = @pair_work.comments.order(:created_at)
      render 'pair_works/show'
    end
  end

  def destroy; end

  private

  def pair_work_reservation_params
    params.require(:pair_work).permit(:reserved_at).merge(buddy_id: current_user.id)
  end
end
