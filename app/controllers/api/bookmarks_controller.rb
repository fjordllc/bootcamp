# frozen_string_literal: true

class API::BookmarksController < API::BaseController
  before_action :require_login
  PEGER_NUMBER = 25

  def index
    bookmarks = Bookmark.where(user_id: current_user.id).order(created_at: :desc)
    @bookmarks = Kaminari.paginate_array(bookmarks).page(params[:page]).per(PEGER_NUMBER)
    return unless params[:bookmarkable_id] && params[:bookmarkable_type]

    @bookmarks = Bookmark.where(user_id: current_user.id, bookmarkable_id: params[:bookmarkable_id], bookmarkable_type: params[:bookmarkable_type])
  end

  def create
    @bookmark = Bookmark.new(
      user: current_user,
      bookmarkable: bookmarkable
    )

    @bookmark.save!
    render json: @bookmark
  end

  def destroy
    Bookmark.find(params[:id]).destroy
    head :no_content
  end

  private

  def bookmarkable
    params[:bookmarkable_type].constantize.find_by(id: params[:bookmarkable_id])
  end
end
