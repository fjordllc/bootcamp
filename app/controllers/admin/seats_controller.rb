# frozen_string_literal: true

class Admin::SeatsController < AdminController
  before_action :set_seat, only: [:edit, :update, :destroy]

  def index
    @seats = Seat.all
  end

  def new
    @seat = Seat.new
  end

  def edit
  end

  def create
    @seat = Seat.new(seat_params)

    if @seat.save
      redirect_to admin_seats_path, notice: "席を作成しました。"
    else
      render :new
    end
  end

  def update
    if @seat.update(seat_params)
      redirect_to admin_seats_path, notice: "席を更新しました。"
    else
      render :edit
    end
  end

  def destroy
    @seat.destroy
    redirect_to admin_seats_path, notice: "席を削除しました。"
  end

  private
    def set_seat
      @seat = Seat.find(params[:id])
    end

    def seat_params
      params.require(:seat).permit(:name)
    end
end
