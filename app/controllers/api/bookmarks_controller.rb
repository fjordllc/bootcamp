# frozen_string_literal: true

class API::BookmarksController < API::BaseController
  PAGER_NUMBER = 25

  def index
    bookmarks = Bookmark.where(user: current_user).order(created_at: :desc)
    @bookmarks = Kaminari.paginate_array(bookmarks).page(params[:page]).per(PAGER_NUMBER)
    return unless params[:bookmarkable_id] && params[:bookmarkable_type]

    @bookmarks = Bookmark.where(
      user: current_user,
      bookmarkable: bookmarkable
    )
  end

  def create
    @bookmark = Bookmark.create!(
      user: current_user,
      bookmarkable: bookmarkable
    )
    render status: :created, json: @bookmark
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
