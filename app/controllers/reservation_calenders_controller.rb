# frozen_string_literal: true

class ReservationCalendersController < ApplicationController
  def index
    this_month = I18n.l(Date.new(Date.current.year, Date.current.month, 1), format: :ym)
    redirect_to action: "show", id: this_month
  end

  def show
    if is_year_and_month(params[:id])
      beggining_of_this_month = Date.new(params[:id].slice(0, 4).to_i, params[:id].slice(4, 2).to_i, 1)
    else
      beggining_of_this_month = Date.current.beginning_of_month
    end

    @this_month = beggining_of_this_month
    @prev_month = beggining_of_this_month.prev_month
    @next_month = beggining_of_this_month.next_month

    @seats = Seat.all
    @reservations = Reservation.where(date: beggining_of_this_month..beggining_of_this_month.end_of_month).includes(:user)
    @memos = Memo.where(date: beggining_of_this_month..beggining_of_this_month.end_of_month)
  end
  private
    def is_year_and_month(params_id)
      /^\d{4}(0[1-9]|1[0-2])$/.match?(params_id)
    end
end
