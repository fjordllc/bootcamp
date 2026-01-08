# frozen_string_literal: true

class PairWorksController < ApplicationController
  before_action :set_my_pair_work, only: %i[edit destroy]
  before_action :set_updatable_pair_work, only: %i[update]

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

  def show
    @pair_work = PairWork.find(params[:id])
    @comments = @pair_work.comments.order(:created_at)
  end

  def edit; end

  def new
    @pair_work = PairWork.new
  end

  def create
    @pair_work = PairWork.new(pair_work_params)
    @pair_work.user = current_user
    set_wip
    if @pair_work.save
      ActiveSupport::Notifications.instrument('pair_work.create', pair_work: @pair_work)
      redirect_to Redirection.determin_url(self, @pair_work), notice: @pair_work.generate_notice_message(:create)
    else
      render :new
    end
  end

  def update
    set_wip
    if @pair_work.update(pair_work_params)
      ActiveSupport::Notifications.instrument('pair_work.update', pair_work: @pair_work)
      redirect_to Redirection.determin_url(self, @pair_work), notice: @pair_work.generate_notice_message(:update)
    else
      render :edit
    end
  end

  def destroy
    @pair_work.destroy
    redirect_to pair_works_url, notice: @pair_work.generate_notice_message(:destroy)
  end

  private

  def pair_work_params
    params.require(:pair_work).permit(:practice_id, :title, :description, :reserved_at, :buddy_id, :channel,
                                      schedules_attributes: %i[id proposed_at _destroy])
  end

  def set_my_pair_work
    @pair_work = current_user.admin? ? PairWork.find(params[:id]) : current_user.pair_works.find(params[:id])
  end

  def set_updatable_pair_work
    @pair_work = if PairWork.update_permission?(current_user, params[:pair_work])
                   PairWork.find(params[:id])
                 else
                   current_user.pair_works.find(params[:id])
                 end
  end

  def set_wip
    @pair_work.wip = params[:commit] == 'WIP'
  end
end
