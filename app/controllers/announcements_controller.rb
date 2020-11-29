# frozen_string_literal: true

class AnnouncementsController < ApplicationController
  before_action :require_login
  before_action :require_admin_login, except: %i(index show)
  before_action :set_announcement, only: %i(show edit update destroy)
  before_action :set_footprints, only: %i(show)

  def index
    @announcements = Announcement.with_avatar
                                 .preload(:comments)
                                 .order(created_at: :desc)
                                 .page(params[:page])
  end

  def show
    footprint!
  end

  def new
    @announcement = Announcement.new(target: "students")
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
      notify_to_slack(@announcement)
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
    def notify_to_slack(announcement)
      link = "<#{url_for(announcement)}|#{announcement.title}>"

      SlackNotification.notify "#{link}",
                               username: "#{announcement.user.login_name} (#{announcement.user.name})",
                               icon_url: announcement.user.avatar_url,
                               channel: "#general",
                               attachments: [{
                                 fallback: "announcement description.",
                                 text: announcement.description
                               }]
    end

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
end
