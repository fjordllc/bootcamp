class AnnouncementsController < ApplicationController
  def new
    @announcement = Announcement.new
  end

  def create
    @announcement = Announcement.new(announcement_params)
    @announcement.user_id = current_user.id
    if @announcement.save
      redirect_to announcements_path
    else
      redirect_to new_announcement_path
    end
  end

  private
    def announcement_params
     params.require(:announcement).permit(:title, :description, :user_id)
    end
end
