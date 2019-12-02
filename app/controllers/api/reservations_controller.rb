# frozen_string_literal: true

class API::ReservationsController < API::BaseController
  before_action :require_login
  before_action :set_reservation, only: %i(destroy)

  def index
    beggining_of_this_month = params[:beggining_of_this_month]
    end_of_this_month = params[:end_of_this_month]
    @reservations = Reservation.where(date: beggining_of_this_month..end_of_this_month).includes(:user)
  end

  def create
    @reservation = Reservation.new(reservation_params)
    @reservation.user = current_user
    if @reservation.save
      render :create, status: :created
    else
      if @reservation.errors.nil?
        head :bad_request
      else
        render status: 409, json: { status: 409, message: @reservation.errors.full_messages }
      end
    end
  end

  def destroy
    @reservation.destroy
  end

  private
    def reservation_params
      params.require(:reservation).permit(
        :date,
        :seat_id
      )
    end

    def set_reservation
      @reservation = current_user.reservations.find(params[:id])
    end
end
