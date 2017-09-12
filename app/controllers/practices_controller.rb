class PracticesController < ApplicationController
  include Gravatarify::Helper
  before_action :require_login
  before_action :set_practice, only: %w(show edit update destroy sort)

  def index
    @categories = Category.order("position")
  end

  def show
    @submission = Submission.new
  end

  def new
    @practice = Practice.new
  end

  def edit
  end

  def create
    @practice = Practice.new(practice_params)

    if @practice.save
      notify "<#{url_for(current_user)}|#{current_user.login_name}>が<#{url_for(@practice)}|#{@practice.title}>を作成しました。",
        username: "#{current_user.login_name}@256interns.com",
        icon_url: gravatar_url(current_user)
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
      notify "#{text}\n```#{diff}```",
        username: "#{current_user.login_name}@256interns.com",
        icon_url: gravatar_url(current_user)
      redirect_to @practice, notice: "プラクティスを更新しました。"
    else
      render :edit
    end
  end

  def destroy
    @practice.destroy
    notify "<#{url_for(current_user)}|#{current_user.login_name}>が<#{url_for(@practice)}|#{@practice.title}>を削除しました。",
      username: "#{current_user.login_name}@256interns.com",
      icon_url: gravatar_url(current_user)
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
        :assignment
      )
    end

    def set_practice
      @practice = Practice.find(params[:id])
    end
end
