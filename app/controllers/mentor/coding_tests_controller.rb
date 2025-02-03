# frozen_string_literal: true

class Mentor::CodingTestsController < ApplicationController
  PER_PAGE = 20

  before_action :require_admin_or_mentor_login, only: %i[index new create edit update]
  before_action :set_coding_test, only: %i[edit update destroy]

  def index
    @coding_tests = CodingTest.joins(:practice)
                              .order('practices.id, coding_tests.position')
                              .page(params[:page])
                              .per(PER_PAGE)
  end

  def new
    @coding_test = CodingTest.new(user: current_user)
  end

  def edit; end

  def create
    @coding_test = CodingTest.new(coding_test_params)
    if @coding_test.save
      redirect_to @coding_test, notice: 'コーディングテストを作成しました。'
    else
      render :new
    end
  end

  def update
    if @coding_test.update(coding_test_params)
      redirect_to @coding_test, notice: 'コーディングテストを更新しました。'
    else
      render :edit
    end
  end

  def destroy
    @coding_test.destroy!
    redirect_to mentor_coding_tests_path, notice: 'コーディングテストを削除しました。'
  end

  private

  def coding_test_params
    params.require(:coding_test).permit(
      :title,
      :description,
      :practice_id,
      :user_id,
      :language,
      coding_test_cases_attributes: %i[id input output _destroy]
    )
  end

  def set_coding_test
    @coding_test = CodingTest.find(params[:id])
  end
end
