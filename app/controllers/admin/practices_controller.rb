# frozen_string_literal: true

class Admin::PracticesController < AdminController
  before_action :set_practice, only: %i[show edit update destroy]

  def index
    @practices = Practice.all
  end

  def show; end

  def new
    @practice = Practice.new
  end

  def create
    @practice = Practice.new(practice_params)
    if @practice.save
      redirect_to admin_practices_url, notice: 'プラクティスを作成しました。'
    else
      render action: 'new'
    end
  end

  def update
    if @practice.update(practice_params)
      redirect_to return_to, notice: 'プラクティスを更新しました。'
    else
      render action: 'edit'
    end
  end

  def destroy
    @practice.destroy
    redirect_to admin_practices_url, notice: 'プラクティスを削除しました。'
  end

  private

  def set_practice
    @practice = Practice.find(params[:id])
  end

  def practice_params
    params.require(:practice).permit(
      :name,
      :title,
      :description,
      :goal,
      :open_product,
      :include_progress,
      :memo
    )
  end

  def return_to
    course_id = params[:practice][:course_id]
    course_id.present? ? course_practices_url(course_id) : admin_practices_url
  end
end
