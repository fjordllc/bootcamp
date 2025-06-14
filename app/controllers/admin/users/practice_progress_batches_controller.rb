# frozen_string_literal: true

class Admin::Users::PracticeProgressBatchesController < AdminController
  before_action :set_user

  def create
    migrator = PracticeProgressMigrator.new(@user)
    migrator.migrate_all

    redirect_to admin_user_practice_progress_index_path(@user), notice: '全ての進捗をコピーしました。'
  end

  private

  def set_user
    @user = User.find(params[:user_id])
  end
end
