# frozen_string_literal: true

class Admin::Users::PracticeProgressBatchesController < AdminController
  before_action :set_user

  def create
    migrator = PracticeProgressMigrator.new(@user)

    result = migrator.migrate_all
    if result
      redirect_to admin_user_practice_progress_path(@user), notice: '全ての進捗をコピーしました。'
    else
      redirect_to admin_user_practice_progress_path(@user), alert: '進捗のコピーに失敗しました。'
    end
  end

  private

  def set_user
    @user = User.find(params[:user_id])
  end
end
