# frozen_string_literal: true

class WorksController < ApplicationController
  before_action :require_login
  before_action :set_my_work, only: %i[edit update destroy]

  def show
    @work = Work.find(params[:id])
  end

  def new
    @work = Work.new
  end

  def edit; end

  def create
    @work = Work.new(work_params)
    @work.user = current_user
    if @work.save
      redirect_to @work, notice: 'ポートフォリオに作品を追加しました。'
    else
      render :new
    end
  end

  def update
    if @work.update(work_params)
      redirect_to @work, notice: '作品を更新しました。'
    else
      render :edit
    end
  end

  def destroy
    @work.destroy
    redirect_to user_portfolio_url(@work.user), notice: 'ポートフォリオから作品を削除しました。'
  end

  private

  def work_params
    params.require(:work).permit(
      :title,
      :description,
      :url,
      :repository,
      :thumbnail,
      :graduation_work
    )
  end

  def set_my_work
    @work = if admin_or_mentor_login?
              Work.find(params[:id])
            else
              current_user.works.find(params[:id])
            end
  end
end
