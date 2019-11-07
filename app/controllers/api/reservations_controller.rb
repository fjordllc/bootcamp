# frozen_string_literal: true

class API::ReservationsController < API::BaseController
  before_action :require_login
  before_action :set_reservation, only: %i(destroy)

  def index
    beggining_of_this_month = params[:begginingOfThisMonth]
    end_of_this_month = params[:endOfThisMonth]
    @reservations = Reservation.where(date: beggining_of_this_month..end_of_this_month).includes(:user)
  end

  def create
    @reservation = Reservation.new(reservation_params)
    @reservation.user = current_user
    if @reservation.save
      render :create, status: :created
    else
      head :bad_request
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
