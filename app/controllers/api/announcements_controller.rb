# frozen_string_literal: true

class API::AnnouncementsController < API::BaseController
  before_action :require_admin_login_for_api, only: %i[destroy]
  before_action :set_announcement, only: %i[show update destroy]
  protect_from_forgery except: %i[create update]

  def index
    @announcements = Announcement.with_avatar
                                 .preload(:comments)
                                 .order(published_at: :desc, created_at: :desc)
                                 .page(params[:page])
  end

  def show; end

  def update
    if !current_user.admin? \
      && (announcement_params['wip'] == 'false' \
      || announcement_params['wip'].nil?)
      head :bad_request
    elsif @announcement.update(announcement_params)
      head :ok
    else
      head :bad_request
    end
  end

  def create
    @announcement = Announcement.new(announcement_params)
    @announcement.user_id = current_user.id
    @announcement.wip = true unless current_user.admin?
    if @announcement.save
      render :create, status: :created
    else
      head :bad_request
    end
  end

  def destroy
    @announcement.destroy
  end

  private

  def announcement_params
    params.fetch(:announcement).permit(:title, :description, :target, :wip)
  end

  def set_announcement
    @announcement = Announcement.find(params[:id])
  end
end
