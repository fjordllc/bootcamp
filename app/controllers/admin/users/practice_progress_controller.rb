# frozen_string_literal: true

class Admin::Users::PracticeProgressController < AdminController
  before_action :set_user

  def index
    @presenter = PracticeProgressPresenter.new(@user)
    @current_course = @user.course
    @rails_course = Course.rails_course
  end

  def create
    migrator = PracticeProgressMigrator.new(@user)
    result = migrator.migrate(params[:practice_id])

    if result[:success]
      redirect_to admin_user_practice_progress_index_path(@user), notice: result[:message]
    else
      redirect_to admin_user_practice_progress_index_path(@user), alert: result[:error]
    end
  end

  def bulk_copy
    migrator = PracticeProgressMigrator.new(@user)
    result = migrator.migrate_all

    redirect_to admin_user_practice_progress_index_path(@user), notice: result[:message]
  end

  private

  def set_user
    @user = User.find(params[:user_id])
  end
end
