# frozen_string_literal: true

class WorksController < ApplicationController
  def show
    @work = Work.find(params[:id])
  end

  def new
    @work = current_user.works.new
  end

  def edit
    @work = current_user.works.find(params[:id])
  end

  def create
    @work = Work.new(work_params)
    @work.user = current_user
    if @work.save
      redirect_to user_portfolio_url(current_user), notice: "ポートフォリオに作品を追加しました。"
    else
      render :new
    end
  end

  def update
    @work = current_user.works.find(params[:id])
    if @work.update(work_params)
      redirect_to user_portfolio_url(current_user), notice: "作品を更新しました。"
    else
      render :edit
    end
  end

  def destroy
    @work = current_user.works.find(params[:id])
    @work.destroy
    redirect_to user_portfolio_url(current_user), notice: "ポートフォリオから作品を削除しました。"
  end

  private

    def work_params
      params.require(:work).permit(
        :title,
        :description,
        :url,
        :repository,
        :thumbnail
      )
    end
end
