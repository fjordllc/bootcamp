class PracticesController < ApplicationController
  before_action :require_login, except: %w(index show)
  before_action :set_practice, only: %w(show edit update destroy sort)
  respond_to :html, :json

  def index
    @practices = Practice.rank(:row_order).to_a
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
      redirect_to @practice, notice: t('practice_was_successfully_created')
    else
      render :new
    end
  end

  def update
    if @practice.update(practice_params)
      flash[:notice] = t('practice_was_successfully_updated')
    end
    respond_with @practice
  end

  def destroy
    @practice.destroy
    redirect_to practices_url, notice: t('practice_was_successfully_deleted')
  end

  private
    def practice_params
      params.require(:practice).permit(
        :title,
        :description,
        :goal,
        :target,
        :row_order
      )
    end

    def set_practice
      @practice = Practice.find(params[:id])
    end
end
