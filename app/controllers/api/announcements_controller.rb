# frozen_string_literal: true

class API::AnnouncementsController < API::BaseController
  protect_from_forgery except: %i[create]
  before_action :set_announcement, only: %i[show update destroy]

  def index
    @announcements = Announcement.with_avatar
                                 .preload(:comments)
                                 .order(published_at: :desc, created_at: :desc)
                                 .page(params[:page])
  end

  def show; end

  def new
    @announcement = Announcement.new(target: 'students')
  end

  def edit
    @announcement.user_id = current_user.id
  end

  def update
    if @announcement.update(announcement_params)
      head :ok
    else
      head :bad_request
    end
  end

  def create
    @announcement = Announcement.new(announcement_params)
    @announcement.user_id = current_user.id
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
    params.require(:announcement).permit(:title, :description, :target, :wip)
  end

  def set_announcement
    @announcement = Announcement.find(params[:id])
  end
end
