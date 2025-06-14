# frozen_string_literal: true

class Admin::Users::PracticeProgressController < AdminController
  before_action :set_user

  def index
    @presenter = PracticeProgressPresenter.new(@user)
    @current_course = @user.course
    @rails_course = Course.rails_course
  end

  def create
    practice_id = practice_progress_params[:practice_id]
    
    unless practice_id.present? && Practice.exists?(practice_id)
      redirect_to admin_user_practice_progress_index_path(@user), alert: 'プラクティスが見つかりません'
      return
    end

    migrator = PracticeProgressMigrator.new(@user)
    result = migrator.migrate(practice_id)

    if result[:success]
      redirect_to admin_user_practice_progress_index_path(@user), notice: result[:message]
    else
      redirect_to admin_user_practice_progress_index_path(@user), alert: result[:error]
    end
  end

  private

  def set_user
    @user = User.find(params[:user_id])
  end

  def practice_progress_params
    params.permit(:practice_id)
  end
end
