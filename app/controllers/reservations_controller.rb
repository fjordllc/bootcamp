# frozen_string_literal: true

class ReservationsController < ApplicationController
  def create
    @reservation = Reservation.new(reservation_params)
    @reservation.user = current_user

    this_month = I18n.l(@reservation.date, format: :ym)

    if @reservation.save
      redirect_to reservation_calender_path(this_month), notice: "予約しました"
    else
      redirect_to reservation_calender_path(this_month), alert: @reservation.errors.full_messages
    end
  end

  def destroy
    @reservation = find_my_reservation
    this_month = I18n.l(@reservation.date, format: :ym)
    @reservation.destroy
    redirect_to reservation_calender_path(this_month), alert: "予約を解約しました"
  end

  private
    def reservation_params
      params.require(:reservation).permit(
        :date,
        :seat_id
      )
    end

    def find_my_reservation
      if admin_login?
        Reservation.find(params[:id])
      else
        current_user.reservations.find(params[:id])
      end
    end
end
