# frozen_string_literal: true

class API::BookmarksController < API::BaseController
  before_action :require_login
  PEGER_NUMBER = 25

  def index
    bookmarks = Bookmark.where(user_id: current_user.id).order(created_at: :desc)
    @bookmarks = Kaminari.paginate_array(bookmarks).page(params[:page]).per(PEGER_NUMBER)
    @bookmarks = Bookmark.where(user_id: current_user.id, report_id: params[:report_id]) if params[:report_id]
  end

  def create
    Bookmark.create(user_id: current_user.id, report_id: params[:report_id])
  end

  def destroy
    Bookmark.find(params[:id]).destroy
    head :no_content
  end
end
