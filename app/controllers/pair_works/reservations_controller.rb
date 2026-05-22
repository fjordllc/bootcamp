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
      render 'pair_works/show', status: :unprocessable_entity
    end
  end

  def update
    @pair_work = PairWork.find(params[:pair_work_id])
    if @pair_work.reserve(pair_work_reservation_params)
      ActiveSupport::Notifications.instrument('pair_work.reschedule', pair_work: @pair_work) if @pair_work.saved_change_to_reserved_at?
      if @pair_work.saved_change_to_buddy_id?
        ActiveSupport::Notifications.instrument('pair_work.rematch', pair_work: @pair_work, past_buddy: @pair_work.past_buddy)
      end
      redirect_to Redirection.determin_url(self, @pair_work), notice: @pair_work.generate_notice_message(:update_reserve)
    else
      @comments = @pair_work.comments.order(:created_at)
      render 'pair_works/show', status: :unprocessable_entity
    end
  end

  def destroy
    @pair_work = PairWork.find(params[:pair_work_id])
    return if current_user != @pair_work.buddy

    if @pair_work.unmatch
      ActiveSupport::Notifications.instrument('pair_work.cancel', pair_work: @pair_work, sender: current_user)
      redirect_to Redirection.determin_url(self, @pair_work), notice: @pair_work.generate_notice_message(:cancel)
    else
      @comments = @pair_work.comments.order(:created_at)
      render 'pair_works/show', status: :unprocessable_entity
    end
  end

  private

  def pair_work_reservation_params
    params.require(:pair_work).permit(:reserved_at).merge(buddy_id: current_user.id)
  end
end
