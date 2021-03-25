# frozen_string_literal: true

class AnnouncementsController < ApplicationController
  before_action :require_login
  before_action :set_announcement, only: %i[show edit update destroy]
  before_action :set_footprints, only: %i[show]

  def index; end

  def show
    footprint!
  end

  def new
    @announcement = Announcement.new(target: 'students')

    return unless params[:id]

    announcement = Announcement.find(params[:id])
    @announcement.title       = announcement.title
    @announcement.description = announcement.description
    @announcement.target = announcement.target
    flash.now[:notice] = 'お知らせをコピーしました。'
  end

  def edit
    @announcement.user_id = current_user.id
  end

  def update
    set_wip
    if @announcement.update(announcement_params)
      redirect_to @announcement, notice: notice_message(@announcement)
    else
      render :edit
    end
  end

  def create
    @announcement = Announcement.new(announcement_params)
    @announcement.user_id = current_user.id
    set_wip
    if @announcement.save
      redirect_to @announcement, notice: notice_message(@announcement)
    else
      render :new
    end
  end

  def destroy
    @announcement.destroy
    redirect_to announcements_path, notice: 'お知らせを削除しました'
  end

  private

  def footprint!
    @announcement.footprints.create_or_find_by(user: current_user) if @announcement.user != current_user
  end

  def set_footprints
    @footprints = @announcement.footprints.with_avatar.order(created_at: :desc)
  end

  def announcement_params
    params.require(:announcement).permit(:title, :description, :target)
  end

  def set_announcement
    @announcement = Announcement.find(params[:id])
  end

  def set_wip
    @announcement.wip = (params[:commit] == 'WIP')
  end

  def notice_message(announcement)
    case params[:action]
    when 'create'
      announcement.wip? ? 'お知らせをWIPとして保存しました。' : 'お知らせを作成しました。'
    when 'update'
      announcement.wip? ? 'お知らせをWIPとして保存しました。' : 'お知らせを更新しました。'
    end
  end
end
