# frozen_string_literal: true

class API::ReservationsController < API::BaseController
  before_action :set_reservation, only: %i(destroy)

  def index
    @reservations = Reservation.where(
      date: params[:beggining_of_this_month]..params[:end_of_this_month]
    ).includes(:user)
  end

  def create
    if reservation_params[:seat_id].instance_of?(Array) || reservation_params[:date].instance_of?(Array)
      create_reservations(seat_id: reservation_params[:seat_id], date: reservation_params[:date])
    else
      @reservation = Reservation.new(reservation_params)
      @reservation.user = current_user
      if @reservation.save
        render :create, status: :created
      else
        render status: :bad_request, json: { message: @reservation.errors.full_messages }
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
      :seat_id,
      { seat_id: [] },
      { date: [] },
    )
  end

  def set_reservation
    @reservation = current_user.reservations.find(params[:id])
  end

  def create_reservations(seat_id:, date:)
    @reservations = []
    values = seat_id if seat_id.instance_of?(Array) && date.instance_of?(String)
    values = date if date.instance_of?(Array) && seat_id.instance_of?(Integer)
    values.each do |value|
      @reservation = Reservation.new(seat_id: value, date: date) if seat_id.instance_of?(Array)
      @reservation = Reservation.new(seat_id: seat_id, date: value) if date.instance_of?(Array)
      @reservation.user = current_user
      @reservation.save
      @reservations << @reservation
    end
    render :index, status: :created
  end
end
