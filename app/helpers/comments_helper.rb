module CommentsHelper
  def recent_comments
    if @_recent_comments
      @_recent_comments
    else
      @_recent_comments = PublicActivity::Activity.order(created_at: :desc).where(recipient_id: current_user.id, read_flag: 0).where.not(owner_id: current_user.id)
    end
  end
end
