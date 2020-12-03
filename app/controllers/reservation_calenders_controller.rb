# frozen_string_literal: true

class ReservationCalendersController < ApplicationController
  before_action :set_seats, only: %w(show)

  def index
    this_month = l(Date.new(Date.current.year, Date.current.month, 1), format: :ym)
    redirect_to action: "show", id: this_month
  end

  def show
    days_of_this_month = beggining_of_this_month..beggining_of_this_month.end_of_month
    @reservations = Reservation.where(date: days_of_this_month).includes(:user)

    @memos = Memo.one_month_memos(beggining_of_this_month)
    @holidays = Holiday.one_month_holidays(beggining_of_this_month)

    @this_month = beggining_of_this_month
    @prev_month = beggining_of_this_month.prev_month
    @next_month = beggining_of_this_month.next_month
  end

  private

  def beggining_of_this_month
    if @beggining_of_this_month.nil?
      @beggining_of_this_month = if year_and_month?(params[:id])
                                   Date.new(params[:id].slice(0, 4).to_i, params[:id].slice(4, 2).to_i, 1)
                                 else
                                   Date.current.beginning_of_month
                                 end
    else
      @beggining_of_this_month
    end
  end

  def year_and_month?(params_id)
    /^\d{4}(0[1-9]|1[0-2])$/.match?(params_id)
  end

  def set_seats
    @seats = []
    Seat.all.order(:name).each do |seat|
      @seats.push(id: seat["id"], name: seat["name"])
    end
  end
end
