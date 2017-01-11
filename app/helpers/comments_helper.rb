module CommentsHelper
  def recent_comments
    @activities = PublicActivity::Activity.order(created_at: :desc).where(recipient_id: current_user.id)
  end
end
