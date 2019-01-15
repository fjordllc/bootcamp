# frozen_string_literal: true

class AnnouncementsController < ApplicationController
  before_action :require_admin_login, except: %i(index show)
  before_action :require_login
  before_action :set_announcement, only: %i(show edit update destroy)
  before_action :set_footprints, only: %i(show)

  def index
    @announcements = Announcement.order(created_at: :desc).page(params[:page])
  end

  def show
    footprint!
  end

  def new
    @announcement = Announcement.new
  end

  def edit
    @announcement.user_id = current_user.id
  end

  def update
    if @announcement.update(announcement_params)
      redirect_to @announcement, notice: "お知らせを更新しました"
    else
      render :edit
    end
  end

  def create
    @announcement = Announcement.new(announcement_params)
    @announcement.user_id = current_user.id
    if @announcement.save
      redirect_to @announcement, notice: "お知らせを作成しました"
    else
      render :new
    end
  end

  def destroy
    @announcement.destroy
    redirect_to announcements_path, notice: "お知らせを削除しました"
  end

  private
    def footprint!
      @announcement.footprints.where(user: current_user).first_or_create if @announcement.user != current_user
    end

    def set_footprints
      @footprints = @announcement.footprints.order(created_at: :desc)
    end

    def announcement_params
      params.require(:announcement).permit(:title, :description)
    end

    def set_announcement
      @announcement = Announcement.find(params[:id])
    end
end
