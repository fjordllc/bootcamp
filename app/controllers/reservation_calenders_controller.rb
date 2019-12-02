# frozen_string_literal: true

class ReservationCalendersController < ApplicationController
  before_action :set_beggining_of_this_month, only: %w(show)
  before_action :set_seats, only: %w(show)

  def index
    this_month = I18n.l(Date.new(Date.current.year, Date.current.month, 1), format: :ym)
    redirect_to action: "show", id: this_month
  end

  def show
    @reservations = Reservation.where(date: @beggining_of_this_month..@beggining_of_this_month.end_of_month).includes(:user)

    set_memos(@beggining_of_this_month)
    set_holiday_jps(@beggining_of_this_month)

    @this_month = @beggining_of_this_month
    @prev_month = @beggining_of_this_month.prev_month
    @next_month = @beggining_of_this_month.next_month
  end

  private
    def set_beggining_of_this_month
      if is_year_and_month(params[:id])
        @beggining_of_this_month = Date.new(params[:id].slice(0, 4).to_i, params[:id].slice(4, 2).to_i, 1)
      else
        @beggining_of_this_month = Date.current.beginning_of_month
      end
    end
    def is_year_and_month(params_id)
      /^\d{4}(0[1-9]|1[0-2])$/.match?(params_id)
    end

    def set_seats
      seats = []
      Seat.all.order(:name).each do |seat|
        se = {}
        se["id"] = seat["id"]
        se["name"] = seat["name"]
        seats.push(se)
      end
      @seats = JSON(seats)
    end

    def set_memos(beggining_of_this_month)
      memos2 = Memo.where(date: beggining_of_this_month..beggining_of_this_month.end_of_month)
      @memos = {}
      memos2.each do |memo|
        @memos[l(memo[:date], format: :ymd_hy)] = memo[:body]
      end
      @memos = JSON(@memos)
    end

    def set_holiday_jps(beggining_of_this_month)
      holiday_jps = {}
      (beggining_of_this_month..beggining_of_this_month.end_of_month).each do |one_day|
        if HolidayJp.holiday?(one_day) || one_day.sunday? || one_day.saturday?
          holiday_jps[l(one_day, format: :ymd_hy)] = 1
        end
      end
      @holiday_jps = JSON(holiday_jps)
    end
end
