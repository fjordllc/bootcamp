class PracticesController < ApplicationController
  before_action :require_login
  before_action :set_practice, only: [:show, :edit, :update, :destroy]

  def index
    @practices = Practice.all
  end

  def show
  end

  def new
    @practice = Practice.new
  end

  def edit
  end

  def create
    @practice = Practice.new(practice_params)

    if @practice.save
      redirect_to @practice, notice: 'Practice was successfully created.'
    else
      render action: 'new'
    end
  end

  def update
    if @practice.update(practice_params)
      redirect_to @practice, notice: 'Practice was successfully updated.'
    else
      render action: "edit"
    end
  end

  def destroy
    @practice.destroy
    redirect_to practices_url
  end

  private
    def practice_params
      params.require(:practice).permit(:title, :description)
    end

    def set_practice
      @practice = Practice.find(params[:id])
    end
end
