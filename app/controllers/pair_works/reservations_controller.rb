# frozen_string_literal: true

class PairWorks::ReservationsController < ApplicationController
  before_action :require_mentor_login, only: %i[create]

  def create
    @pair_work = PairWork.find(params[:pair_work_id])
    reservation_params = pair_work_reservation_params
    notification_kinds = []
    new_reserved_at = Time.zone.parse(reservation_params[:reserved_at])
    notification_kinds << 'pair_work.reschedule' if @pair_work.solved? && @pair_work.reserved_at != new_reserved_at
    notification_kinds << 'pair_work.rematch' if @pair_work.solved? && @pair_work.buddy_id != reservation_params[:buddy_id]
    notification_kinds << 'pair_work.reserve' if notification_kinds.empty?
    if @pair_work.reserve(reservation_params)
      notification_kinds.each do |kind|
        ActiveSupport::Notifications.instrument(kind, pair_work: @pair_work)
      end
      redirect_to Redirection.determin_url(self, @pair_work), notice: @pair_work.generate_notice_message(:reserve)
    else
      @comments = @pair_work.comments.order(:created_at)
      render 'pair_works/show'
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
      render 'pair_works/show'
    end
  end

  private

  def pair_work_reservation_params
    params.require(:pair_work).permit(:reserved_at).merge(buddy_id: current_user.id)
  end
end
