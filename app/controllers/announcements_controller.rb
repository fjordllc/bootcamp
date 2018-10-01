class AnnouncementsController < ApplicationController
  before_action :require_admin_login, except: %i(index show)
  before_action :set_announcement, only: %i(show edit update destroy)

  def index
    @announcements = Announcement.order(created_at: :desc)
  end

  def show
  end

  def new
    @announcement = Announcement.new
  end

  def edit
    @announcement.user_id = current_user.id
  end

  def update
    if @announcement.update(announcement_params)
      redirect_to @announcement, notice: t("announcement_was_successfully_updated")
    else
      render :edit
    end
  end

  def create
    @announcement = Announcement.new(announcement_params)
    @announcement.user_id = current_user.id
    if @announcement.save
      redirect_to @announcement, notice: t("announcement_was_successfully_created")
    else
      render :new
    end
  end
  
  def destroy
    @announcement.destroy
    redirect_to announcements_path, notice: "お知らせを削除しました"
  end

  private
    def announcement_params
     params.require(:announcement).permit(:title, :description)
    end

    def set_announcement
      @announcement = Announcement.find(params[:id])
    end
end
