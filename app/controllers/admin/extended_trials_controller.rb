# frozen_string_literal: true

class Admin::ExtendedTrialsController < AdminController
  before_action :set_extended_trial, only: %i[edit update]
  def new
    @extended_trial = ExtendedTrial.new(start_at: Time.current.beginning_of_day)
  end

  def create
    @extended_trial = ExtendedTrial.new(extended_trial_params)
    if @extended_trial.save
      redirect_to admin_extended_trials_path, notice: 'お試し延長を作成しました。'
    else
      render :new
    end
  end

  def index
    @extended_trials = ExtendedTrial.order(created_at: :desc)
  end

  def edit; end

  def update
    if @extended_trial.update(extended_trial_params)
      redirect_to admin_extended_trials_path, notice: 'お試し延長を更新しました。'
    else
      render :edit
    end
  end

  private

  def set_extended_trial
    @extended_trial = ExtendedTrial.find(params[:id])
  end

  def extended_trial_params
    params.require(:extended_trial).permit(:start_at, :end_at, :title)
  end
end
