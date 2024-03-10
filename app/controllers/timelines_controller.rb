# frozen_string_literal: true

class TimelinesController < ApplicationController
  def index
    @timelines = Timeline.all.order(created_at: :desc)
    @user = current_user
  end

  def new
    @timeline = Timeline.new
  end

  def create
    @timeline = Timeline.new(timeline_params)
    if @timeline.save
      flash[:notice] = 'ツイートを送信しました。'
    else
      flash[:alert] = 'ツイートに失敗しました。'
    end
    redirect_to timelines_path
  end

  private

  def timeline_params
    params.require(:timeline).permit(:context).merge(user_id: current_user.id)
  end
end
