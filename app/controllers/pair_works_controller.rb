# frozen_string_literal: true

class PairWorksController < ApplicationController
  before_action :set_pair_work, only: %i[show edit update destroy]

  PAGER_NUMBER = 10
  def index
    @pair_works = PairWork.by_target(params[:target])
                          .with_avatar
                          .preload(:practice)
                          .order(:published_at)
                          .page(params[:page])
                          .per(PAGER_NUMBER)
    @pair_works_property = PairWork.generate_pair_works_property(params[:target])
  end

  def show; end

  def edit; end

  def new
    @pair_work = PairWork.new
  end

  def create
    @pair_work = PairWork.new(pair_work_params)
    @pair_work.user = current_user
    set_wip
    if @pair_work.save
      Newspaper.publish(:pair_work_create, { pair_work: @pair_work, schedules: params[:pair_work][:schedules] })
      redirect_to @pair_work, notice: @pair_work.generate_notice_message(:create)

    else
      render :new
    end
  end

  def update
    set_wip
    if @pair_work.update(pair_work_params)
      Newspaper.publish(:pair_work_update, { pair_work: @pair_work })
      redirect_to @pair_work, notice: @pair_work.generate_notice_message(:update)
    else
      render :edit
    end
  end

  def destroy
    @pair_work.destroy
    redirect_to pair_works_url, notice: 'ペアワークを削除しました。'
  end

  private

  def pair_work_params
    fields = %i[practice_id title description reserved_at buddy_id channel]
    fields << :pair_work_schedules if params[:action] == 'create'

    params.require(:pair_work).permit(*fields)
  end

  def set_pair_work
    @pair_work = PairWork.find(params[:id])
  end

  def set_wip
    @pair_work.wip = params[:commit] == 'WIP'
  end
end
