# frozen_string_literal: true

class Users::TimelinesController < ApplicationController
  before_action :set_user

  def index
    @timelines = Timeline.where(user_id: params[:user_id]).order(created_at: :desc)
  end

  def new
    @timeline = Timeline.new
  end

  def create
    @timeline = Timeline.new(timeline_params)
    if current_user == @user && @timeline.save
      flash[:notice] = 'ツイートを送信しました。'
    else
      flash[:alert] = 'ツイートに失敗しました。'
    end
    redirect_to user_timelines_path
  end

  private

  def set_user
    @user = User.find(params[:user_id])
  end

  def timeline_params
    params.permit(:context, :user_id)
  end
end
