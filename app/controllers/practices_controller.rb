# frozen_string_literal: true

class PracticesController < ApplicationController
  before_action :require_admin_login, except: %i(show)
  before_action :require_login
  before_action :set_course, only: %i(new)
  before_action :set_practice, only: %w(show edit update destroy sort)

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
      SlackNotification.notify "<#{url_for(current_user)}|#{current_user.login_name}>が<#{url_for(@practice)}|#{@practice.title}>を作成しました。",
        username: "#{current_user.login_name}@bootcamp.fjord.jp",
        icon_url: url_for(current_user.avatar)
      redirect_to @practice, notice: "プラクティスを作成しました。"
    else
      render :new
    end
  end

  def update
    old_practice = @practice.dup
    if @practice.update(practice_params)
      text = "<#{url_for(current_user)}|#{current_user.login_name}>が<#{url_for(@practice)}|#{@practice.title}>を編集しました。"
      diff = Diffy::Diff.new(old_practice.all_text + "\n", @practice.all_text + "\n", context: 1).to_s
      SlackNotification.notify "#{text}\n```#{diff}```",
        username: "#{current_user.login_name}@bootcamp.fjord.jp",
        icon_url: url_for(current_user.avatar)
      redirect_to @practice, notice: "プラクティスを更新しました。"
    else
      render :edit
    end
  end

  def destroy
    @practice.destroy
    SlackNotification.notify "<#{url_for(current_user)}|#{current_user.login_name}>が<#{url_for(@practice)}|#{@practice.title}>を削除しました。",
      username: "#{current_user.login_name}@bootcamp.fjord.jp",
      icon_url: url_for(current_user.avatar)
    redirect_to practices_url, notice: "プラクティスを削除しました。"
  end

  private
    def practice_params
      params.require(:practice).permit(
        :title,
        :description,
        :goal,
        :category_id,
        :position,
        :submission,
        :open_product
      )
    end

    def set_practice
      @practice = Practice.find(params[:id])
    end

    def set_course
      @course = Course.find(params[:course_id]) if params[:course_id]
    end
end
